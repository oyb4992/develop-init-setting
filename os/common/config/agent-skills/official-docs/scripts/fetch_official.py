#!/usr/bin/env python3
"""Fetch text from an allowlisted official documentation URL with a local cache."""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import os
import re
import sys
import tempfile
import time
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qsl, urljoin, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener

DEFAULT_MAX_AGE = 86_400
DEFAULT_MAX_BYTES = 5 * 1024 * 1024
SENSITIVE_QUERY_KEYS = {
    "api_key",
    "apikey",
    "authorization",
    "credential",
    "password",
    "secret",
    "token",
}


def parse_args() -> argparse.Namespace:
    skill_dir = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(
        description="Fetch an allowlisted HTTPS documentation page as text."
    )
    parser.add_argument("url")
    parser.add_argument(
        "--allowlist",
        type=Path,
        default=skill_dir / "references" / "official-domains.txt",
    )
    parser.add_argument("--cache-dir", type=Path)
    parser.add_argument("--max-age", type=int, default=DEFAULT_MAX_AGE)
    parser.add_argument("--max-bytes", type=int, default=DEFAULT_MAX_BYTES)
    parser.add_argument("--refresh", action="store_true")
    parser.add_argument("--raw", action="store_true", help="Do not extract HTML text")
    return parser.parse_args()


def load_allowlist(path: Path) -> set[str]:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise ValueError(f"cannot read allowlist: {exc}") from exc

    hosts = {
        line.strip().lower().rstrip(".")
        for line in lines
        if line.strip() and not line.lstrip().startswith("#")
    }
    if not hosts:
        raise ValueError("allowlist is empty")
    return hosts


def validate_url(url: str, allowed_hosts: set[str]) -> None:
    parsed = urlsplit(url)
    host = (parsed.hostname or "").lower().rstrip(".")
    if parsed.scheme != "https":
        raise ValueError("only HTTPS URLs are allowed")
    if parsed.username or parsed.password:
        raise ValueError("credentials in URLs are not allowed")
    try:
        port = parsed.port
    except ValueError as exc:
        raise ValueError("invalid URL port") from exc
    if port not in (None, 443):
        raise ValueError("only the default HTTPS port is allowed")
    if host not in allowed_hosts:
        raise ValueError(f"hostname is not allowlisted: {host or '<missing>'}")
    sensitive = {
        key.lower() for key, _ in parse_qsl(parsed.query, keep_blank_values=True)
    } & SENSITIVE_QUERY_KEYS
    if sensitive:
        raise ValueError(
            "sensitive query parameter names are not allowed: "
            + ", ".join(sorted(sensitive))
        )


class SafeRedirectHandler(HTTPRedirectHandler):
    def __init__(self, allowed_hosts: set[str]) -> None:
        super().__init__()
        self.allowed_hosts = allowed_hosts

    def redirect_request(self, req, fp, code, msg, headers, newurl):  # type: ignore[no-untyped-def]
        target = urljoin(req.full_url, newurl)
        validate_url(target, self.allowed_hosts)
        return super().redirect_request(req, fp, code, msg, headers, target)


class TextExtractor(HTMLParser):
    BLOCK_TAGS = {
        "article",
        "blockquote",
        "br",
        "dd",
        "div",
        "dl",
        "dt",
        "figcaption",
        "footer",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
        "header",
        "li",
        "main",
        "nav",
        "ol",
        "p",
        "pre",
        "section",
        "table",
        "td",
        "th",
        "tr",
        "ul",
    }
    SKIP_TAGS = {"script", "style", "noscript", "svg"}

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self.skip_depth = 0

    def handle_starttag(self, tag: str, attrs) -> None:  # type: ignore[no-untyped-def]
        if tag in self.SKIP_TAGS:
            self.skip_depth += 1
        elif not self.skip_depth and tag in self.BLOCK_TAGS:
            self.parts.append("\n")

    def handle_endtag(self, tag: str) -> None:
        if tag in self.SKIP_TAGS and self.skip_depth:
            self.skip_depth -= 1
        elif not self.skip_depth and tag in self.BLOCK_TAGS:
            self.parts.append("\n")

    def handle_data(self, data: str) -> None:
        if not self.skip_depth:
            self.parts.append(data)

    def text(self) -> str:
        joined = html.unescape("".join(self.parts))
        lines = [re.sub(r"[ \t\f\v]+", " ", line).strip() for line in joined.splitlines()]
        return "\n".join(line for line in lines if line)


def default_cache_dir() -> Path:
    configured = os.environ.get("OFFICIAL_DOCS_CACHE_DIR")
    if configured:
        return Path(configured).expanduser()
    xdg = os.environ.get("XDG_CACHE_HOME")
    if xdg:
        return Path(xdg).expanduser() / "official-docs"
    return Path.home() / ".cache" / "official-docs"


def usable_cache_dir(requested: Path | None) -> Path:
    primary = requested.expanduser() if requested else default_cache_dir()
    try:
        primary.mkdir(parents=True, exist_ok=True)
        return primary
    except OSError:
        fallback = Path(tempfile.gettempdir()) / "official-docs-cache"
        fallback.mkdir(parents=True, exist_ok=True)
        return fallback


def cache_paths(cache_dir: Path, url: str) -> tuple[Path, Path]:
    key = hashlib.sha256(url.encode("utf-8")).hexdigest()
    return cache_dir / f"{key}.body", cache_dir / f"{key}.json"


def read_cache(
    body_path: Path, metadata_path: Path, max_age: int
) -> tuple[bytes, dict[str, object]] | None:
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        fetched_at = float(metadata["fetched_at"])
        if time.time() - fetched_at > max_age:
            return None
        return body_path.read_bytes(), metadata
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError):
        return None


def is_textual(content_type: str) -> bool:
    media_type = content_type.split(";", 1)[0].strip().lower()
    return (
        media_type.startswith("text/")
        or media_type in {"application/json", "application/xml", "application/xhtml+xml"}
        or media_type.endswith("+json")
        or media_type.endswith("+xml")
    )


def fetch(
    url: str, allowed_hosts: set[str], max_bytes: int
) -> tuple[bytes, dict[str, object]]:
    opener = build_opener(SafeRedirectHandler(allowed_hosts))
    request = Request(
        url,
        headers={
            "Accept": "text/html,text/plain,application/json,application/xml;q=0.9,*/*;q=0.1",
            "User-Agent": "official-docs-skill/1.0",
        },
    )
    with opener.open(request, timeout=20) as response:
        final_url = response.geturl()
        validate_url(final_url, allowed_hosts)
        content_type = response.headers.get("Content-Type", "")
        if not is_textual(content_type):
            raise ValueError(f"non-text response rejected: {content_type or '<missing>'}")
        content_length = response.headers.get("Content-Length")
        if content_length and int(content_length) > max_bytes:
            raise ValueError(f"response exceeds {max_bytes} bytes")
        body = response.read(max_bytes + 1)
        if len(body) > max_bytes:
            raise ValueError(f"response exceeds {max_bytes} bytes")
        metadata: dict[str, object] = {
            "content_type": content_type,
            "fetched_at": time.time(),
            "final_url": final_url,
        }
        return body, metadata


def decode_body(body: bytes, content_type: str) -> str:
    charset_match = re.search(r"charset=([^;\s]+)", content_type, flags=re.IGNORECASE)
    charset = charset_match.group(1).strip('"\'') if charset_match else "utf-8"
    try:
        return body.decode(charset, errors="replace")
    except LookupError:
        return body.decode("utf-8", errors="replace")


def render(body: bytes, metadata: dict[str, object], raw: bool, source: str) -> str:
    content_type = str(metadata.get("content_type", ""))
    text = decode_body(body, content_type)
    if not raw and content_type.lower().startswith(("text/html", "application/xhtml+xml")):
        parser = TextExtractor()
        parser.feed(text)
        text = parser.text()
    return (
        f"SOURCE: {metadata.get('final_url', '')}\n"
        f"FETCH: {source}\n"
        f"CONTENT-TYPE: {content_type}\n\n"
        f"{text.rstrip()}\n"
    )


def main() -> int:
    args = parse_args()
    try:
        allowed_hosts = load_allowlist(args.allowlist)
        validate_url(args.url, allowed_hosts)
        if args.max_age < 0 or args.max_bytes < 1:
            raise ValueError("max-age must be non-negative and max-bytes must be positive")
        cache_dir = usable_cache_dir(args.cache_dir)
        body_path, metadata_path = cache_paths(cache_dir, args.url)

        cached = None if args.refresh else read_cache(body_path, metadata_path, args.max_age)
        if cached:
            body, metadata = cached
            validate_url(str(metadata.get("final_url", args.url)), allowed_hosts)
            source = "cache"
        else:
            body, metadata = fetch(args.url, allowed_hosts, args.max_bytes)
            body_path.write_bytes(body)
            metadata_path.write_text(json.dumps(metadata, indent=2), encoding="utf-8")
            source = "network"

        sys.stdout.write(render(body, metadata, args.raw, source))
        return 0
    except (HTTPError, URLError, OSError, ValueError) as exc:
        print(f"fetch_official: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

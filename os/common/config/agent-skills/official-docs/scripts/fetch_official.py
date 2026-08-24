#!/usr/bin/env python3
"""Fetch text from an allowlisted official documentation URL with a local cache."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import re
import stat
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
DEFAULT_MAX_CACHE_BYTES = 50 * 1024 * 1024
SKILL_DIR = Path(__file__).resolve().parent.parent
DEFAULT_ALLOWLIST = SKILL_DIR / "references" / "official-domains.txt"
CACHE_KEY_PATTERN = re.compile(r"official-docs-[0-9a-f]{64}")
CACHE_TEMP_PATTERN = re.compile(
    r"official-docs-[0-9a-f]{64}\.(?:body|json)\.official-docs-v1\.\d+\.tmp"
)
CACHE_FORMAT = "official-docs-v1"
TEMP_FILE_MAX_AGE = 3_600
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
    parser = argparse.ArgumentParser(
        description="Fetch an allowlisted HTTPS documentation page as text."
    )
    parser.add_argument("url")
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
    PREFORMATTED_TAGS = {"code", "pre"}

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self.preformatted: dict[str, str] = {}
        self.preformatted_depth = 0
        self.skip_depth = 0

    def handle_starttag(self, tag: str, attrs) -> None:  # type: ignore[no-untyped-def]
        if tag in self.SKIP_TAGS:
            self.skip_depth += 1
        elif not self.skip_depth:
            if tag in self.PREFORMATTED_TAGS:
                self.preformatted_depth += 1
            if tag in self.BLOCK_TAGS:
                self.parts.append("\n")

    def handle_endtag(self, tag: str) -> None:
        if tag in self.SKIP_TAGS and self.skip_depth:
            self.skip_depth -= 1
        elif not self.skip_depth:
            if tag in self.BLOCK_TAGS:
                self.parts.append("\n")
            if tag in self.PREFORMATTED_TAGS and self.preformatted_depth:
                self.preformatted_depth -= 1

    def handle_data(self, data: str) -> None:
        if not self.skip_depth:
            if self.preformatted_depth:
                token = f"\x00official-docs-pre-{len(self.preformatted)}\x00"
                self.preformatted[token] = data
                self.parts.append(token)
            else:
                self.parts.append(data)

    def text(self) -> str:
        lines = [
            re.sub(r"[ \t\f\v]+", " ", line).strip()
            for line in "".join(self.parts).splitlines()
        ]
        text = "\n".join(line for line in lines if line)
        for token, data in self.preformatted.items():
            text = text.replace(token, data)
        return text


def default_cache_dir() -> Path:
    configured = os.environ.get("OFFICIAL_DOCS_CACHE_DIR")
    if configured:
        return Path(configured).expanduser()
    xdg = os.environ.get("XDG_CACHE_HOME")
    if xdg:
        return Path(xdg).expanduser() / "official-docs"
    return Path.home() / ".cache" / "official-docs"


def cache_dir_if_writable(path: Path) -> Path | None:
    try:
        path.mkdir(mode=0o700, parents=True, exist_ok=True)
        info = path.lstat()
        if not stat.S_ISDIR(info.st_mode) or path.is_symlink():
            return None
        getuid = getattr(os, "getuid", None)
        if getuid and info.st_uid != getuid():
            return None
        if os.name != "nt" and info.st_mode & 0o022:
            return None
        with tempfile.NamedTemporaryFile(prefix=".write-test-", dir=path):
            pass
        return path
    except OSError:
        return None


def usable_cache_dir(requested: Path | None) -> Path | None:
    primary = requested.expanduser() if requested else default_cache_dir()
    usable = cache_dir_if_writable(primary)
    if usable:
        return usable

    user_key = hashlib.sha256(str(Path.home()).encode("utf-8")).hexdigest()[:12]
    fallback = Path(tempfile.gettempdir()) / f"official-docs-cache-{user_key}"
    return cache_dir_if_writable(fallback)


def cache_paths(cache_dir: Path, url: str) -> tuple[Path, Path]:
    key = "official-docs-" + hashlib.sha256(url.encode("utf-8")).hexdigest()
    return cache_dir / f"{key}.body", cache_dir / f"{key}.json"


def read_cache(
    body_path: Path, metadata_path: Path, max_age: int, max_bytes: int
) -> tuple[bytes, dict[str, object]] | None:
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        if (
            metadata["cache_format"] != CACHE_FORMAT
            or metadata["cache_key"] != body_path.stem
        ):
            return None
        fetched_at = float(metadata["fetched_at"])
        now = time.time()
        if not math.isfinite(fetched_at) or fetched_at > now or now - fetched_at > max_age:
            return None
        with body_path.open("rb") as body_file:
            body = body_file.read(max_bytes + 1)
        if len(body) > max_bytes:
            return None
        expected_hash = str(metadata["body_sha256"])
        if hashlib.sha256(body).hexdigest() != expected_hash:
            return None
        return body, metadata
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError):
        return None


def write_cache(
    body_path: Path,
    metadata_path: Path,
    body: bytes,
    metadata: dict[str, object],
) -> None:
    stored_metadata = {
        **metadata,
        "body_sha256": hashlib.sha256(body).hexdigest(),
        "cache_format": CACHE_FORMAT,
        "cache_key": body_path.stem,
    }
    suffix = f".{CACHE_FORMAT}.{os.getpid()}.tmp"
    body_temp = body_path.with_name(body_path.name + suffix)
    metadata_temp = metadata_path.with_name(metadata_path.name + suffix)
    try:
        body_temp.write_bytes(body)
        metadata_temp.write_text(json.dumps(stored_metadata, indent=2), encoding="utf-8")
        os.replace(body_temp, body_path)
        os.replace(metadata_temp, metadata_path)
    finally:
        for temp_path in (body_temp, metadata_temp):
            try:
                temp_path.unlink()
            except OSError:
                pass


def prune_cache(cache_dir: Path, max_bytes: int = DEFAULT_MAX_CACHE_BYTES) -> None:
    now = time.time()
    for path in cache_dir.glob("*.tmp"):
        if not CACHE_TEMP_PATTERN.fullmatch(path.name):
            continue
        try:
            info = path.stat()
            if now - info.st_mtime > TEMP_FILE_MAX_AGE:
                path.unlink()
        except OSError:
            pass

    keys = {
        path.stem
        for pattern in ("*.body", "*.json")
        for path in cache_dir.glob(pattern)
        if CACHE_KEY_PATTERN.fullmatch(path.stem)
    }
    entries: list[tuple[float, int, tuple[Path, ...]]] = []
    for key in keys:
        paths = (cache_dir / f"{key}.body", cache_dir / f"{key}.json")
        existing = tuple(path for path in paths if path.exists())
        try:
            if len(existing) != 2:
                modified = max(path.stat().st_mtime for path in existing)
                if now - modified > TEMP_FILE_MAX_AGE:
                    for path in existing:
                        try:
                            path.unlink()
                        except OSError:
                            pass
                continue
            metadata = json.loads(paths[1].read_text(encoding="utf-8"))
            if (
                metadata["cache_format"] != CACHE_FORMAT
                or metadata["cache_key"] != key
            ):
                continue
            size = sum(path.stat().st_size for path in existing)
            modified = max(path.stat().st_mtime for path in existing)
        except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError):
            try:
                modified = max(path.stat().st_mtime for path in existing)
                if now - modified > TEMP_FILE_MAX_AGE:
                    for path in paths:
                        try:
                            path.unlink()
                        except OSError:
                            pass
            except (OSError, ValueError):
                pass
            continue
        entries.append((modified, size, paths))

    total = sum(size for _, size, _ in entries)
    for _, size, paths in sorted(entries, key=lambda entry: entry[0]):
        if total <= max_bytes:
            break
        removed = 0
        for path in paths:
            try:
                path_size = path.stat().st_size
                path.unlink()
                removed += path_size
            except OSError:
                pass
        total -= min(size, removed)


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
        allowed_hosts = load_allowlist(DEFAULT_ALLOWLIST)
        validate_url(args.url, allowed_hosts)
        if args.max_age < 0 or args.max_bytes < 1:
            raise ValueError("max-age must be non-negative and max-bytes must be positive")
        cache_dir = usable_cache_dir(args.cache_dir)
        if cache_dir:
            prune_cache(cache_dir)
            body_path, metadata_path = cache_paths(cache_dir, args.url)
            cached = (
                None
                if args.refresh
                else read_cache(body_path, metadata_path, args.max_age, args.max_bytes)
            )
        else:
            body_path = metadata_path = None
            cached = None
        if cached:
            body, metadata = cached
            validate_url(str(metadata.get("final_url", args.url)), allowed_hosts)
            source = "cache"
        else:
            body, metadata = fetch(args.url, allowed_hosts, args.max_bytes)
            if cache_dir and body_path and metadata_path:
                try:
                    write_cache(body_path, metadata_path, body, metadata)
                    prune_cache(cache_dir)
                except OSError as exc:
                    print(
                        f"fetch_official: cache unavailable for this response: {exc}",
                        file=sys.stderr,
                    )
            source = "network"

        sys.stdout.write(render(body, metadata, args.raw, source))
        return 0
    except (HTTPError, URLError, OSError, ValueError) as exc:
        print(f"fetch_official: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

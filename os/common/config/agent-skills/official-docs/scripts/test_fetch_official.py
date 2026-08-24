#!/usr/bin/env python3
"""Offline checks for fetch_official.py security and text extraction."""

from __future__ import annotations

import argparse
import io
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from unittest.mock import Mock, patch
from urllib.request import Request

import fetch_official


class FakeResponse:
    def __init__(
        self,
        body: bytes = b"ok",
        *,
        url: str = "https://docs.example.com/guide",
        content_type: str = "text/plain; charset=utf-8",
        content_length: str | None = None,
    ) -> None:
        self.body = body
        self.url = url
        self.headers = {"Content-Type": content_type}
        if content_length is not None:
            self.headers["Content-Length"] = content_length

    def __enter__(self):  # type: ignore[no-untyped-def]
        return self

    def __exit__(self, *args) -> None:  # type: ignore[no-untyped-def]
        return None

    def geturl(self) -> str:
        return self.url

    def read(self, amount: int) -> bytes:
        return self.body[:amount]


class FetchOfficialTest(unittest.TestCase):
    def setUp(self) -> None:
        self.allowed = {"docs.example.com"}

    def test_accepts_only_allowlisted_default_https(self) -> None:
        fetch_official.validate_url("https://docs.example.com/guide", self.allowed)

        rejected = (
            "http://docs.example.com/guide",
            "https://other.example.com/guide",
            "https://user:pass@docs.example.com/guide",
            "https://docs.example.com:8443/guide",
            "https://docs.example.com/search?token=secret",
        )
        for url in rejected:
            with self.subTest(url=url), self.assertRaises(ValueError):
                fetch_official.validate_url(url, self.allowed)

    def test_extracts_visible_html_text(self) -> None:
        parser = fetch_official.TextExtractor()
        parser.feed("<h1>Title</h1><script>secret()</script><p>Visible text</p>")
        self.assertEqual(parser.text(), "Title\nVisible text")

    def test_preserves_entity_literals_and_code_indentation(self) -> None:
        parser = fetch_official.TextExtractor()
        parser.feed(
            "<div>\n    Ordinary prose\n</div>"
            "<code>&amp;lt;tag&amp;gt;</code>"
            "<pre>root:\n  child: value</pre>"
        )
        self.assertEqual(
            parser.text(), "Ordinary prose\n&lt;tag&gt;\nroot:\n  child: value"
        )

    def test_loads_the_shipped_allowlist(self) -> None:
        self.assertEqual(
            fetch_official.load_allowlist(fetch_official.DEFAULT_ALLOWLIST),
            {
                "docs.gradle.org",
                "docs.hibernate.org",
                "docs.oracle.com",
                "docs.spring.io",
                "hibernate.org",
                "maven.apache.org",
                "react.dev",
                "typescriptlang.org",
                "www.typescriptlang.org",
            },
        )

    def test_cli_cannot_replace_the_shipped_allowlist(self) -> None:
        with patch.object(
            sys,
            "argv",
            ["fetch_official.py", "https://docs.example.com", "--allowlist", "other.txt"],
        ), redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            fetch_official.parse_args()

    def test_rejects_unsafe_http_responses_and_redirects(self) -> None:
        handler = fetch_official.SafeRedirectHandler(self.allowed)
        request = Request("https://docs.example.com/start")
        with self.assertRaises(ValueError):
            handler.redirect_request(
                request, None, 302, "Found", {}, "https://other.example.com/guide"
            )
        redirected = handler.redirect_request(
            request, None, 302, "Found", {}, "/guide"
        )
        self.assertIsNotNone(redirected)
        self.assertEqual(redirected.full_url, "https://docs.example.com/guide")

        accepted = FakeResponse(body=b"document")
        with patch.object(
            fetch_official,
            "build_opener",
            return_value=Mock(open=Mock(return_value=accepted)),
        ) as build_opener:
            body, metadata = fetch_official.fetch(
                "https://docs.example.com/guide", self.allowed, max_bytes=10
            )
        installed_handler = build_opener.call_args.args[0]
        self.assertIsInstance(installed_handler, fetch_official.SafeRedirectHandler)
        self.assertEqual(installed_handler.allowed_hosts, self.allowed)
        self.assertEqual(body, b"document")
        self.assertEqual(metadata["final_url"], "https://docs.example.com/guide")

        rejected = (
            FakeResponse(url="https://other.example.com/guide"),
            FakeResponse(content_type="application/octet-stream"),
            FakeResponse(content_length="11"),
            FakeResponse(body=b"x" * 11),
        )
        for response in rejected:
            with self.subTest(response=response), patch.object(
                fetch_official,
                "build_opener",
                return_value=Mock(open=Mock(return_value=response)),
            ), self.assertRaises(ValueError):
                fetch_official.fetch(
                    "https://docs.example.com/guide", self.allowed, max_bytes=10
                )

    def test_cache_enforces_size_time_and_integrity(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            body_path = Path(temp_dir) / "entry.body"
            metadata_path = Path(temp_dir) / "entry.json"
            body = b"document"
            metadata = {
                "content_type": "text/plain",
                "fetched_at": time.time(),
                "final_url": "https://docs.example.com/guide",
            }
            fetch_official.write_cache(body_path, metadata_path, body, metadata)

            self.assertEqual(
                fetch_official.read_cache(body_path, metadata_path, 60, len(body)),
                (
                    body,
                    {
                        **metadata,
                        "body_sha256": fetch_official.hashlib.sha256(body).hexdigest(),
                        "cache_format": fetch_official.CACHE_FORMAT,
                        "cache_key": body_path.stem,
                    },
                ),
            )
            self.assertIsNone(
                fetch_official.read_cache(body_path, metadata_path, 60, len(body) - 1)
            )

            stored = json.loads(metadata_path.read_text(encoding="utf-8"))
            for invalid_time in (float("nan"), float("inf"), time.time() + 60):
                stored["fetched_at"] = invalid_time
                metadata_path.write_text(json.dumps(stored), encoding="utf-8")
                self.assertIsNone(
                    fetch_official.read_cache(body_path, metadata_path, 60, len(body))
                )

            stored["fetched_at"] = time.time() - 61
            metadata_path.write_text(json.dumps(stored), encoding="utf-8")
            self.assertIsNone(
                fetch_official.read_cache(body_path, metadata_path, 60, len(body))
            )

            metadata_path.write_text("{", encoding="utf-8")
            self.assertIsNone(
                fetch_official.read_cache(body_path, metadata_path, 60, len(body))
            )

            stored["fetched_at"] = time.time()
            stored["body_sha256"] = "wrong"
            metadata_path.write_text(json.dumps(stored), encoding="utf-8")
            self.assertIsNone(
                fetch_official.read_cache(body_path, metadata_path, 60, len(body))
            )

    def test_cache_write_failure_does_not_lose_fetched_body(self) -> None:
        args = argparse.Namespace(
            url="https://docs.example.com/guide",
            cache_dir=None,
            max_age=60,
            max_bytes=100,
            refresh=False,
            raw=False,
        )
        metadata = {
            "content_type": "text/plain",
            "fetched_at": time.time(),
            "final_url": args.url,
        }
        with tempfile.TemporaryDirectory() as temp_dir, patch.object(
            fetch_official, "parse_args", return_value=args
        ), patch.object(
            fetch_official, "load_allowlist", return_value={"docs.example.com"}
        ) as load_allowlist, patch.object(
            fetch_official, "usable_cache_dir", return_value=Path(temp_dir)
        ), patch.object(
            fetch_official, "fetch", return_value=(b"document", metadata)
        ), patch.object(
            fetch_official, "write_cache", side_effect=OSError("disk full")
        ), redirect_stdout(io.StringIO()) as stdout, redirect_stderr(
            io.StringIO()
        ) as stderr:
            self.assertEqual(fetch_official.main(), 0)
            load_allowlist.assert_called_once_with(fetch_official.DEFAULT_ALLOWLIST)
            self.assertIn("document", stdout.getvalue())
            self.assertIn("cache unavailable", stderr.getvalue())

    def test_disabled_cache_still_returns_network_body(self) -> None:
        args = argparse.Namespace(
            url="https://docs.example.com/guide",
            cache_dir=None,
            max_age=60,
            max_bytes=100,
            refresh=False,
            raw=False,
        )
        metadata = {
            "content_type": "text/plain",
            "fetched_at": time.time(),
            "final_url": args.url,
        }
        with patch.object(
            fetch_official, "parse_args", return_value=args
        ), patch.object(
            fetch_official, "load_allowlist", return_value={"docs.example.com"}
        ), patch.object(
            fetch_official, "usable_cache_dir", return_value=None
        ), patch.object(
            fetch_official, "fetch", return_value=(b"document", metadata)
        ) as fetch, patch.object(
            fetch_official, "write_cache"
        ) as write_cache, patch.object(
            fetch_official, "prune_cache"
        ) as prune_cache, redirect_stdout(io.StringIO()) as stdout:
            self.assertEqual(fetch_official.main(), 0)
            fetch.assert_called_once()
            write_cache.assert_not_called()
            prune_cache.assert_not_called()
            self.assertIn("document", stdout.getvalue())

    def test_refresh_skips_an_existing_cache_entry(self) -> None:
        args = argparse.Namespace(
            url="https://docs.example.com/guide",
            cache_dir=None,
            max_age=60,
            max_bytes=100,
            refresh=True,
            raw=False,
        )
        metadata = {
            "content_type": "text/plain",
            "fetched_at": time.time(),
            "final_url": args.url,
        }
        with tempfile.TemporaryDirectory() as temp_dir, patch.object(
            fetch_official, "parse_args", return_value=args
        ), patch.object(
            fetch_official, "load_allowlist", return_value={"docs.example.com"}
        ), patch.object(
            fetch_official, "usable_cache_dir", return_value=Path(temp_dir)
        ), patch.object(
            fetch_official, "read_cache"
        ) as read_cache, patch.object(
            fetch_official, "fetch", return_value=(b"document", metadata)
        ), patch.object(
            fetch_official, "write_cache"
        ), patch.object(
            fetch_official, "prune_cache"
        ), redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
            self.assertEqual(fetch_official.main(), 0)
            read_cache.assert_not_called()

    def test_prunes_oldest_cache_entries_to_total_limit(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            cache_dir = Path(temp_dir)
            old_key = "official-docs-" + "0" * 64
            new_key = "official-docs-" + "1" * 64
            for key, modified in ((old_key, 1), (new_key, 2)):
                body_path = cache_dir / f"{key}.body"
                metadata_path = cache_dir / f"{key}.json"
                body_path.write_bytes(b"1234")
                metadata_path.write_text(
                    json.dumps(
                        {
                            "cache_format": fetch_official.CACHE_FORMAT,
                            "cache_key": key,
                        }
                    ),
                    encoding="utf-8",
                )
                os.utime(body_path, (modified, modified))
                os.utime(metadata_path, (modified, modified))

            new_size = sum(
                path.stat().st_size
                for path in (
                    cache_dir / f"{new_key}.body",
                    cache_dir / f"{new_key}.json",
                )
            )
            fetch_official.prune_cache(cache_dir, max_bytes=new_size)
            self.assertFalse((cache_dir / f"{old_key}.body").exists())
            self.assertFalse((cache_dir / f"{old_key}.json").exists())
            self.assertTrue((cache_dir / f"{new_key}.body").exists())
            self.assertTrue((cache_dir / f"{new_key}.json").exists())

            unrelated = cache_dir / "unrelated.json"
            unrelated.write_text("{}", encoding="utf-8")
            unrelated_key = "2" * 64
            unrelated_hash_body = cache_dir / f"{unrelated_key}.body"
            unrelated_hash_metadata = cache_dir / f"{unrelated_key}.json"
            unrelated_hash_body.write_bytes(b"unrelated")
            unrelated_hash_metadata.write_text("{}", encoding="utf-8")
            active_temp = cache_dir / (
                "official-docs-"
                f"{'3' * 64}.body.{fetch_official.CACHE_FORMAT}.{os.getpid()}.tmp"
            )
            stale_temp = cache_dir / (
                "official-docs-"
                f"{'4' * 64}.json.{fetch_official.CACHE_FORMAT}.{os.getpid()}.tmp"
            )
            unrelated_temp = cache_dir / f"{'5' * 64}.body.{os.getpid()}.tmp"
            active_temp.write_bytes(b"active")
            stale_temp.write_bytes(b"stale")
            unrelated_temp.write_bytes(b"unrelated")
            stale_time = time.time() - fetch_official.TEMP_FILE_MAX_AGE - 1
            os.utime(stale_temp, (stale_time, stale_time))
            fetch_official.prune_cache(cache_dir, max_bytes=0)
            self.assertTrue(unrelated.exists())
            self.assertTrue(unrelated_hash_body.exists())
            self.assertTrue(unrelated_hash_metadata.exists())
            self.assertTrue(active_temp.exists())
            self.assertFalse(stale_temp.exists())
            self.assertTrue(unrelated_temp.exists())

            incomplete_key = "official-docs-" + "6" * 64
            incomplete_body = cache_dir / f"{incomplete_key}.body"
            incomplete_body.write_bytes(b"incomplete")
            metadata_only_key = "official-docs-" + "8" * 64
            incomplete_metadata = cache_dir / f"{metadata_only_key}.json"
            incomplete_metadata.write_text(
                json.dumps(
                    {
                        "cache_format": fetch_official.CACHE_FORMAT,
                        "cache_key": metadata_only_key,
                    }
                ),
                encoding="utf-8",
            )
            stale_time = time.time() - fetch_official.TEMP_FILE_MAX_AGE - 1
            os.utime(incomplete_body, (stale_time, stale_time))
            os.utime(incomplete_metadata, (stale_time, stale_time))
            fetch_official.prune_cache(cache_dir, max_bytes=0)
            self.assertFalse(incomplete_body.exists())
            self.assertFalse(incomplete_metadata.exists())

            failing_orphan = cache_dir / f"{'official-docs-' + '9' * 64}.body"
            failing_orphan.write_bytes(b"orphan")
            os.utime(failing_orphan, (stale_time, stale_time))
            original_unlink = Path.unlink

            def fail_selected_unlink(path: Path, *args, **kwargs) -> None:  # type: ignore[no-untyped-def]
                if path == failing_orphan:
                    raise OSError("busy")
                original_unlink(path, *args, **kwargs)

            with patch.object(Path, "unlink", fail_selected_unlink):
                fetch_official.prune_cache(cache_dir, max_bytes=0)
            self.assertTrue(failing_orphan.exists())

    def test_disables_cache_when_primary_and_fallback_are_unwritable(self) -> None:
        with patch.object(
            fetch_official, "cache_dir_if_writable", side_effect=(None, None)
        ):
            self.assertIsNone(fetch_official.usable_cache_dir(Path("unwritable")))

    def test_cache_directory_must_be_private_owned_directory(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            safe = root / "safe"
            self.assertEqual(fetch_official.cache_dir_if_writable(safe), safe)
            self.assertEqual(safe.stat().st_mode & 0o022, 0)

            unsafe = root / "unsafe"
            unsafe.mkdir(mode=0o777)
            unsafe.chmod(0o777)
            self.assertIsNone(fetch_official.cache_dir_if_writable(unsafe))

            link = root / "link"
            link.symlink_to(safe, target_is_directory=True)
            self.assertIsNone(fetch_official.cache_dir_if_writable(link))

    def test_uses_private_per_user_fallback_when_primary_is_unsafe(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            primary = root / "primary"
            primary.mkdir()
            primary.chmod(0o777)
            temp_root = root / "temp"
            user_key = fetch_official.hashlib.sha256(
                str(Path.home()).encode("utf-8")
            ).hexdigest()[:12]
            expected = temp_root / f"official-docs-cache-{user_key}"
            with patch.object(
                fetch_official, "default_cache_dir", return_value=primary
            ), patch.object(fetch_official.tempfile, "gettempdir", return_value=str(temp_root)):
                self.assertEqual(fetch_official.usable_cache_dir(None), expected)
            self.assertFalse(expected.is_symlink())
            self.assertEqual(expected.stat().st_mode & 0o077, 0)

    def test_readme_install_blocks_handle_existing_targets(self) -> None:
        repo_root = Path(__file__).resolve().parents[6]
        readme = (repo_root / "README.md").read_text(encoding="utf-8")
        blocks = dict(
            re.findall(r"```bash\n# (Kiro CLI|Codex)\n(.*?)\n```", readme, re.DOTALL)
        )
        source = repo_root / "os/common/config/agent-skills/official-docs"
        targets = {
            "Kiro CLI": ".kiro/skills/official-docs",
            "Codex": ".codex/skills/official-docs",
        }
        self.assertEqual(set(blocks), set(targets))

        for name, relative_target in targets.items():
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temp_dir:
                install_home = Path(temp_dir) / "home"
                target = install_home / relative_target
                block = blocks[name].replace("$HOME", "$INSTALL_TEST_HOME").replace(
                    "$PWD", "$INSTALL_TEST_REPO"
                )
                env = {
                    **os.environ,
                    "INSTALL_TEST_HOME": str(install_home),
                    "INSTALL_TEST_REPO": str(repo_root),
                }

                def run_block() -> subprocess.CompletedProcess[str]:
                    return subprocess.run(
                        ["bash"],
                        input=block,
                        text=True,
                        capture_output=True,
                        cwd=repo_root,
                        env=env,
                        check=False,
                    )

                self.assertEqual(run_block().returncode, 0)
                self.assertTrue(target.is_symlink())
                self.assertEqual(target.resolve(), source)

                target.unlink()
                target.mkdir()
                self.assertNotEqual(run_block().returncode, 0)
                self.assertTrue(target.is_dir())
                self.assertFalse((target / "official-docs").exists())

                target.rmdir()
                target.write_text("keep", encoding="utf-8")
                self.assertNotEqual(run_block().returncode, 0)
                self.assertEqual(target.read_text(encoding="utf-8"), "keep")

                target.unlink()
                target.symlink_to(Path(temp_dir) / "old", target_is_directory=True)
                self.assertEqual(run_block().returncode, 0)
                self.assertEqual(target.resolve(), source)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Offline checks for fetch_official.py security and text extraction."""

from __future__ import annotations

import unittest

import fetch_official


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


if __name__ == "__main__":
    unittest.main()

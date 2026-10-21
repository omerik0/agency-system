#!/usr/bin/env python3
"""Validate a YouTube link and print its 11-character video id.

Usage: python3 tools/youtube_id.py "<url>"

Prints the id and exits 0, or prints "REJECT: <reason>" to stderr and exits 1.
Standard library only; no network access and no file writes.
"""
import re
import sys
from urllib.parse import parse_qs, urlsplit

ID_RE = re.compile(r"[A-Za-z0-9_-]{11}")
YOUTUBE_HOSTS = {"youtube.com", "www.youtube.com", "m.youtube.com"}
NOCOOKIE_HOSTS = {"youtube-nocookie.com", "www.youtube-nocookie.com"}
SHORT_HOST = "youtu.be"


class Reject(Exception):
    pass


def valid_id(value):
    # fullmatch: the whole string must be the id, not just its first 11 characters
    return bool(ID_RE.fullmatch(value))


def video_id(url):
    if not url:
        raise Reject("empty input")
    if any(ord(c) <= 0x20 or ord(c) >= 0x7F for c in url):
        raise Reject("whitespace, control or non-ASCII character in the link")
    if not url.startswith("https://"):
        raise Reject("scheme must be exactly https")

    parts = urlsplit(url)
    netloc = parts.netloc
    if "@" in netloc:
        raise Reject("username or password in the link")
    if ":" in netloc:
        raise Reject("port in the link")
    host = netloc.lower()
    path = parts.path

    if host == SHORT_HOST:
        candidate = path[1:] if path.startswith("/") else path
        if not valid_id(candidate):
            raise Reject("youtu.be path must be exactly an 11-character id")
        return candidate

    if host in YOUTUBE_HOSTS:
        if path == "/watch":
            values = parse_qs(parts.query).get("v", [])
            if len(values) != 1:
                raise Reject("watch link needs exactly one v parameter")
            if not valid_id(values[0]):
                raise Reject("v is not an 11-character id")
            return values[0]
        segments = path.split("/")
        if len(segments) == 3 and segments[0] == "" and segments[1] in ("shorts", "embed"):
            if not valid_id(segments[2]):
                raise Reject("path id is not an 11-character id")
            return segments[2]
        raise Reject("unsupported youtube.com path")

    if host in NOCOOKIE_HOSTS:
        segments = path.split("/")
        if len(segments) == 3 and segments[0] == "" and segments[1] == "embed":
            if not valid_id(segments[2]):
                raise Reject("path id is not an 11-character id")
            return segments[2]
        raise Reject("youtube-nocookie.com accepts only /embed/<id>")

    raise Reject("host is not an allowed YouTube host")


def main(argv):
    if len(argv) != 2:
        print("REJECT: expected exactly one argument (the link)", file=sys.stderr)
        return 1
    try:
        print(video_id(argv[1]))
    except Reject as reason:
        print("REJECT: %s" % reason, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

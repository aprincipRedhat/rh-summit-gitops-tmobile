#!/usr/bin/env python3
"""Ensure pipeline values define exactly one node with replacementTarget: true; print hostName."""
from __future__ import annotations

import sys


def main() -> None:
    try:
        import yaml  # type: ignore
    except ImportError as exc:
        sys.stderr.write("PyYAML required\n")
        raise SystemExit(1) from exc

    if len(sys.argv) != 2:
        sys.stderr.write("usage: validate_replacement_marker.py <merged-pipeline-values.yaml>\n")
        raise SystemExit(2)

    with open(sys.argv[1], encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    nodes = data.get("nodes") or []
    if not isinstance(nodes, list):
        sys.stderr.write("nodes must be a list\n")
        raise SystemExit(1)

    marked = [n for n in nodes if isinstance(n, dict) and n.get("replacementTarget")]
    if len(marked) != 1:
        sys.stderr.write(
            f"expected exactly one node with replacementTarget: true, found {len(marked)}\n"
        )
        raise SystemExit(1)

    host = marked[0].get("hostName") or marked[0].get("hostname")
    if not host:
        sys.stderr.write("replacement node must set hostName\n")
        raise SystemExit(1)

    print(host)


if __name__ == "__main__":
    main()

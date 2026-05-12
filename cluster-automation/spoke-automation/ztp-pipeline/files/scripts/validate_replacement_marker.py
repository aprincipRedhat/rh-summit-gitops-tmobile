#!/usr/bin/env python3
"""Ensure pipeline values define exactly one node with replacementTarget: true; print hostName."""
from __future__ import annotations

import sys


def _node_dicts_for_marker(data: dict) -> list:
    """Full node dicts from nodes[], else dict entries under nodeGroups (masters then workers)."""
    nodes = data.get("nodes") or []
    if isinstance(nodes, list) and len(nodes) > 0:
        return [n for n in nodes if isinstance(n, dict)]
    out = []
    ng = data.get("nodeGroups") or {}
    if isinstance(ng, dict):
        for key in ("masters", "workers"):
            for item in ng.get(key) or []:
                if isinstance(item, dict):
                    out.append(item)
    return out


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

    nodes = _node_dicts_for_marker(data)
    marked = [n for n in nodes if n.get("replacementTarget")]
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

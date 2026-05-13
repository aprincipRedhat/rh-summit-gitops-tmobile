#!/usr/bin/env python3
"""Remove replacementTarget from each entry in nodes[] (write merged values before final helm template)."""
from __future__ import annotations

import sys


def main() -> None:
    try:
        import yaml  # type: ignore
    except ImportError as exc:
        sys.stderr.write("PyYAML required\n")
        raise SystemExit(1) from exc

    if len(sys.argv) != 2:
        sys.stderr.write("usage: strip_replacement_marker.py <merged-pipeline-values.yaml>\n")
        raise SystemExit(2)

    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    nodes = data.get("nodes") or []
    if isinstance(nodes, list):
        for n in nodes:
            if isinstance(n, dict):
                n.pop("replacementTarget", None)
                n.pop("replacementPhase", None)

    ng = data.get("nodeGroups")
    if isinstance(ng, dict):
        for key in ("masters", "workers"):
            seq = ng.get(key) or []
            if not isinstance(seq, list):
                continue
            for n in seq:
                if isinstance(n, dict):
                    n.pop("replacementTarget", None)
                    n.pop("replacementPhase", None)

    with open(path, "w", encoding="utf-8") as f:
        yaml.dump(
            data,
            f,
            default_flow_style=False,
            sort_keys=False,
            allow_unicode=True,
        )


if __name__ == "__main__":
    main()

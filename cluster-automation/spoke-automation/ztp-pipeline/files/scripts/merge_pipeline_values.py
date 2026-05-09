#!/usr/bin/env python3
"""Deep-merge two YAML files (patch overrides base). Used by Tekton before helm template."""
from __future__ import annotations

import sys


def _deep_merge(base: dict, patch: dict) -> dict:
    for key, val in patch.items():
        if (
            key in base
            and isinstance(base[key], dict)
            and isinstance(val, dict)
        ):
            _deep_merge(base[key], val)
        else:
            base[key] = val
    return base


def main() -> None:
    try:
        import yaml  # type: ignore
    except ImportError as exc:
        sys.stderr.write("PyYAML is required (apk add py3-yaml / pip install pyyaml)\n")
        raise SystemExit(1) from exc

    if len(sys.argv) != 4:
        sys.stderr.write(
            "usage: merge_pipeline_values.py <base.yaml> <patch.yaml> <out.yaml>\n"
        )
        raise SystemExit(2)

    with open(sys.argv[1], encoding="utf-8") as f:
        base = yaml.safe_load(f) or {}
    with open(sys.argv[2], encoding="utf-8") as f:
        patch = yaml.safe_load(f) or {}

    if not isinstance(base, dict):
        sys.stderr.write("base YAML must be a mapping at root\n")
        raise SystemExit(1)
    if not isinstance(patch, dict):
        sys.stderr.write("patch YAML must be a mapping at root\n")
        raise SystemExit(1)

    merged = _deep_merge(base, patch)
    with open(sys.argv[3], "w", encoding="utf-8") as f:
        yaml.dump(
            merged,
            f,
            default_flow_style=False,
            sort_keys=False,
            allow_unicode=True,
        )


if __name__ == "__main__":
    main()

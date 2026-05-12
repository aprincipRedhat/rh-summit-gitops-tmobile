#!/usr/bin/env python3
"""Helpers for nodeGroups (masters/workers), legacy nodeHostnames, and flat nodes[]."""
from __future__ import annotations

import sys
from typing import Any


def _host_from_item(item: Any) -> str | None:
    if isinstance(item, str) and item.strip():
        return item.strip()
    if isinstance(item, dict):
        h = item.get("hostName") or item.get("hostname")
        if h:
            return str(h).strip()
    return None


def hostnames_from_values(data: dict[str, Any]) -> list[str]:
    """Ordered list: masters first, then workers; then legacy nodeHostnames; else from nodes[]."""
    out: list[str] = []
    ng = data.get("nodeGroups") or {}
    if isinstance(ng, dict):
        for key in ("masters", "workers"):
            for item in ng.get(key) or []:
                h = _host_from_item(item)
                if h and h not in out:
                    out.append(h)
        if out:
            return out
    for h in data.get("nodeHostnames") or []:
        if isinstance(h, str) and h.strip() and h.strip() not in out:
            out.append(h.strip())
    if out:
        return out
    for n in data.get("nodes") or []:
        if isinstance(n, dict):
            h = _host_from_item(n)
            if h and h not in out:
                out.append(h)
    return out


def has_inventory_for_render(data: dict[str, Any]) -> bool:
    """True if merged/base values can drive ztp-spoke (nodes, nodeHostnames, or nodeGroups)."""
    if data.get("nodes"):
        return True
    if data.get("nodeHostnames"):
        return True
    ng = data.get("nodeGroups") or {}
    if isinstance(ng, dict):
        if (ng.get("masters") or ng.get("workers")):
            return True
    return False


def main() -> None:
    if len(sys.argv) != 3:
        sys.stderr.write(
            "usage: node_inventory.py <hostnames|check-render> <pipeline-values.yaml>\n"
        )
        raise SystemExit(2)
    cmd, path = sys.argv[1:3]
    try:
        import yaml  # type: ignore
    except ImportError as exc:
        sys.stderr.write("PyYAML required\n")
        raise SystemExit(1) from exc
    with open(path, encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    if not isinstance(data, dict):
        sys.stderr.write("YAML root must be a mapping\n")
        raise SystemExit(1)
    if cmd == "hostnames":
        for h in hostnames_from_values(data):
            print(h)
        return
    if cmd == "check-render":
        if not has_inventory_for_render(data):
            sys.stderr.write(
                "pipeline values must define nodeGroups (masters/workers), "
                "nodeHostnames, or nodes (e.g. after MAC discovery merge)\n"
            )
            raise SystemExit(1)
        return
    sys.stderr.write(f"unknown command: {cmd}\n")
    raise SystemExit(2)


if __name__ == "__main__":
    main()

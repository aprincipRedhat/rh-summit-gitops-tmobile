#!/usr/bin/env python3
"""Emit replacement-flow for Tekton: none | full (stdout only)."""
from __future__ import annotations

import os
import sys
from pathlib import Path

_scripts = Path(__file__).resolve().parent
if str(_scripts) not in sys.path:
    sys.path.insert(0, str(_scripts))
import node_inventory  # noqa: E402


def _try_yaml():
    try:
        import yaml  # type: ignore
    except ImportError:
        return None
    return yaml


def _cluster_instance_hosts(docs: list) -> set[str]:
    hosts: set[str] = set()
    for doc in docs:
        if not isinstance(doc, dict):
            continue
        if doc.get("kind") != "ClusterInstance":
            continue
        spec = doc.get("spec") or {}
        for n in spec.get("nodes") or []:
            if not isinstance(n, dict):
                continue
            h = n.get("hostName") or n.get("hostname")
            if h:
                hosts.add(str(h))
    return hosts


def _desired_hosts(data: dict) -> set[str]:
    return set(node_inventory.hostnames_from_values(data))


def _node_dicts_for_marker(data: dict) -> list:
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
    if len(sys.argv) != 4:
        sys.stderr.write(
            "usage: detect_cluster_replacement.py <pipeline-values.yaml> "
            "<manifests.yaml-or-empty> <cluster-exists-true|false>\n"
        )
        raise SystemExit(2)

    values_path, manifest_path, cluster_exists = sys.argv[1:4]
    if cluster_exists.strip().lower() != "true":
        print("none", end="")
        return

    yaml = _try_yaml()
    if yaml is None:
        sys.stderr.write("PyYAML required\n")
        raise SystemExit(1)

    if not manifest_path or not os.path.isfile(manifest_path):
        print("none", end="")
        return

    with open(values_path, encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    marked = [
        n
        for n in _node_dicts_for_marker(data)
        if n.get("replacementTarget")
    ]
    if len(marked) == 1:
        print("full", end="")
        return

    with open(manifest_path, encoding="utf-8") as f:
        raw = f.read()
    docs = list(yaml.safe_load_all(raw))
    current = _cluster_instance_hosts(docs)
    desired = _desired_hosts(data)
    if desired and current != desired:
        print("full", end="")
        return

    print("none", end="")


if __name__ == "__main__":
    main()

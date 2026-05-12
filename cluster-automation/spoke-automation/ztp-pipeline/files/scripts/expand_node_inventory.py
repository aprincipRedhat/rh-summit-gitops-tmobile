#!/usr/bin/env python3
"""If nodes[] is empty but nodeGroups is set, expand into nodes[] for helm / validation."""
from __future__ import annotations

import copy
import sys


def _host_item(item):
    if isinstance(item, str) and item.strip():
        return item.strip(), {}
    if isinstance(item, dict):
        h = item.get("hostName") or item.get("hostname")
        if h:
            return str(h).strip(), {k: v for k, v in item.items() if k not in ("hostName", "hostname")}
    return None, {}


def expand(data: dict) -> dict:
    nodes = data.get("nodes")
    if isinstance(nodes, list) and len(nodes) > 0:
        return data
    ng = data.get("nodeGroups")
    if not isinstance(ng, dict):
        return data
    masters = ng.get("masters") or []
    workers = ng.get("workers") or []
    if not masters and not workers:
        return data
    cd = copy.deepcopy(data.get("clusterDefaults") or {})
    wd_raw = data.get("workerClusterDefaults")
    if isinstance(wd_raw, dict) and len(wd_raw) > 0:
        wd = copy.deepcopy(wd_raw)
    else:
        wd = copy.deepcopy(cd)
        wd["nodeRole"] = "worker"
    out: list = []
    for item in masters:
        host, extra = _host_item(item)
        if not host:
            continue
        base = copy.deepcopy(cd)
        base.update(extra)
        base["hostName"] = host
        out.append(base)
    for item in workers:
        host, extra = _host_item(item)
        if not host:
            continue
        base = copy.deepcopy(wd)
        base.update(extra)
        base["hostName"] = host
        out.append(base)
    data["nodes"] = out
    return data


def main() -> None:
    try:
        import yaml  # type: ignore
    except ImportError as exc:
        sys.stderr.write("PyYAML required\n")
        raise SystemExit(1) from exc
    if len(sys.argv) != 2:
        sys.stderr.write("usage: expand_node_inventory.py <pipeline-values.yaml>\n")
        raise SystemExit(2)
    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    if not isinstance(data, dict):
        sys.stderr.write("YAML root must be a mapping\n")
        raise SystemExit(1)
    expand(data)
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

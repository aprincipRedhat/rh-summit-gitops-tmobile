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


def _bmc_address(template: str, hostname: str, index: int) -> str:
    """Expand bmcAddressTemplate: {hostname} / %s → hostname, {index} / %d → index."""
    result = template.replace("{hostname}", hostname).replace("{index}", str(index))
    # printf-style: first %s → hostname, first %d → index
    try:
        result = result % hostname
    except (TypeError, ValueError):
        pass
    return result


def _bmc_creds_name(cluster_name: str, hostname: str) -> str:
    """Mirror the ztp-spoke helper: bmc-<clusterName>-<hostname>."""
    return f"bmc-{cluster_name}-{hostname}"


def _nic_mapping_for_role(data: dict, role: str) -> dict:
    """Return the first nicMapping entry for the given role (masters or workers)."""
    nic_mappings = data.get("nicMappings") or {}
    role_key = "masters" if role == "master" else "workers"
    entries = nic_mappings.get(role_key) or []
    if entries and isinstance(entries[0], dict):
        return entries[0]
    # Fallback to legacy clusterDefaults.nicMapping if present
    return (data.get("clusterDefaults") or {}).get("nicMapping") or {
        "logicalName": "eno1",
        "redfishMemberMatch": "Embedded",
    }


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
    # Remove singular nicMapping from clusterDefaults — it lives in nicMappings now
    cd.pop("nicMapping", None)
    wd_raw = data.get("workerClusterDefaults")
    if isinstance(wd_raw, dict) and len(wd_raw) > 0:
        wd = copy.deepcopy(wd_raw)
        wd.pop("nicMapping", None)
    else:
        wd = copy.deepcopy(cd)
        wd["nodeRole"] = "worker"
    bmc_template: str = data.get("bmcAddressTemplate") or ""
    cluster_name: str = (data.get("cluster") or {}).get("name") or ""
    out: list = []
    idx = 0
    for item in masters:
        host, extra = _host_item(item)
        if not host:
            continue
        base = copy.deepcopy(cd)
        base.update(extra)
        base["hostName"] = host
        if "nicMapping" not in base:
            base["nicMapping"] = _nic_mapping_for_role(data, "master")
        if bmc_template and "bmcAddress" not in base:
            base["bmcAddress"] = _bmc_address(bmc_template, host, idx)
        if cluster_name and "bmcCredentialsName" not in base:
            base["bmcCredentialsName"] = {"name": _bmc_creds_name(cluster_name, host)}
        out.append(base)
        idx += 1
    for item in workers:
        host, extra = _host_item(item)
        if not host:
            continue
        base = copy.deepcopy(wd)
        base.update(extra)
        base["hostName"] = host
        if "nicMapping" not in base:
            base["nicMapping"] = _nic_mapping_for_role(data, "worker")
        if bmc_template and "bmcAddress" not in base:
            base["bmcAddress"] = _bmc_address(bmc_template, host, idx)
        if cluster_name and "bmcCredentialsName" not in base:
            base["bmcCredentialsName"] = {"name": _bmc_creds_name(cluster_name, host)}
        out.append(base)
        idx += 1
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

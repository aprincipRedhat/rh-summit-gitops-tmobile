#!/usr/bin/env python3
"""
Minimal Redfish-compatible fake BMC for ZTP pipeline MAC-discovery testing.

Serves static Redfish responses. Credentials are configurable via env vars
BMC_USERNAME / BMC_PASSWORD (defaults: admin / redfish).

Embedded.1 interface returns a fake MAC for redfishMemberMatch: Embedded.
NIC.2 interface returns a second fake MAC (for worker/alternate NIC testing).
"""
import base64
import json
import os
import sys
import http.server

USERNAME = os.environ.get("BMC_USERNAME", "admin")
PASSWORD = os.environ.get("BMC_PASSWORD", "redfish")

IFACE_MAC_EMBEDDED = os.environ.get("BMC_MAC_EMBEDDED", "AA:BB:CC:11:22:33")
IFACE_MAC_NIC2     = os.environ.get("BMC_MAC_NIC2",     "AA:BB:CC:44:55:66")

RESPONSES: dict = {
    "/redfish/v1": {
        "@odata.id":   "/redfish/v1",
        "@odata.type": "#ServiceRoot.v1_5_0.ServiceRoot",
        "Id":          "RootService",
        "Name":        "Root Service",
        "Systems":     {"@odata.id": "/redfish/v1/Systems"},
    },
    "/redfish/v1/Systems": {
        "@odata.id":   "/redfish/v1/Systems",
        "@odata.type": "#ComputerSystemCollection.ComputerSystemCollection",
        "Members":     [{"@odata.id": "/redfish/v1/Systems/1"}],
        "Members@odata.count": 1,
    },
    "/redfish/v1/Systems/1": {
        "@odata.id":   "/redfish/v1/Systems/1",
        "@odata.type": "#ComputerSystem.v1_5_0.ComputerSystem",
        "Id": "1",
        "Name": "Fake Node",
        "EthernetInterfaces": {"@odata.id": "/redfish/v1/Systems/1/EthernetInterfaces"},
    },
    "/redfish/v1/Systems/1/EthernetInterfaces": {
        "@odata.id":   "/redfish/v1/Systems/1/EthernetInterfaces",
        "@odata.type": "#EthernetInterfaceCollection.EthernetInterfaceCollection",
        "Members": [
            {"@odata.id": "/redfish/v1/Systems/1/EthernetInterfaces/Embedded.1"},
            {"@odata.id": "/redfish/v1/Systems/1/EthernetInterfaces/NIC.2"},
        ],
        "Members@odata.count": 2,
    },
    "/redfish/v1/Systems/1/EthernetInterfaces/Embedded.1": {
        "@odata.id":        "/redfish/v1/Systems/1/EthernetInterfaces/Embedded.1",
        "@odata.type":      "#EthernetInterface.v1_4_0.EthernetInterface",
        "Name":             "Embedded NIC 1",
        "MACAddress":       IFACE_MAC_EMBEDDED,
        "PermanentMACAddress": IFACE_MAC_EMBEDDED,
        "LinkStatus":       "Up",
        "SpeedMbps":        10000,
    },
    "/redfish/v1/Systems/1/EthernetInterfaces/NIC.2": {
        "@odata.id":        "/redfish/v1/Systems/1/EthernetInterfaces/NIC.2",
        "@odata.type":      "#EthernetInterface.v1_4_0.EthernetInterface",
        "Name":             "NIC Slot 2 Port 1",
        "MACAddress":       IFACE_MAC_NIC2,
        "PermanentMACAddress": IFACE_MAC_NIC2,
        "LinkStatus":       "Down",
        "SpeedMbps":        25000,
    },
}


class RedfishHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):  # noqa: N802
        sys.stderr.write(f"[fake-bmc] {self.address_string()} - {fmt % args}\n")
        sys.stderr.flush()

    def _check_auth(self) -> bool:
        auth = self.headers.get("Authorization", "")
        if not auth.startswith("Basic "):
            return False
        try:
            user, _, pwd = base64.b64decode(auth[6:]).decode().partition(":")
            return user == USERNAME and pwd == PASSWORD
        except Exception:
            return False

    def _send_json(self, status: int, body: dict | None = None) -> None:
        payload = json.dumps(body or {}).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):  # noqa: N802
        path = self.path.split("?")[0].rstrip("/") or "/redfish/v1"

        if not self._check_auth():
            self.send_response(401)
            self.send_header("WWW-Authenticate", 'Basic realm="Fake Redfish"')
            self.end_headers()
            return

        data = RESPONSES.get(path)
        if data is None:
            self._send_json(404, {"error": f"path {path!r} not found"})
            return

        self._send_json(200, data)


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    server = http.server.HTTPServer(("0.0.0.0", port), RedfishHandler)
    sys.stderr.write(
        f"[fake-bmc] Redfish BMC simulator listening on :{port}\n"
        f"[fake-bmc] Username={USERNAME}  MAC(Embedded.1)={IFACE_MAC_EMBEDDED}  MAC(NIC.2)={IFACE_MAC_NIC2}\n"
    )
    sys.stderr.flush()
    server.serve_forever()

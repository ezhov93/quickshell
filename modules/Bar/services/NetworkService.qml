pragma Singleton

import Quickshell
import Quickshell.Networking
import Quickshell.Io
import QtQuick
import "../../../services" as Services

Singleton {
  id: root
  property bool active: false
  readonly property var devices: Networking.devices.values
  readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
  readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
  readonly property var connectedDevice: wired ?? wifi
  readonly property var wifiNetwork: wifi?.networks.values.find(n => n.connected) ?? null
  readonly property bool needsFallback: !connectedDevice
  readonly property string type: wired ? "ethernet" : wifi ? "wifi" : fallbackType
  readonly property string name: wired ? "Ethernet" : wifi ? (wifiNetwork?.name || "Wi-Fi") : fallbackName
  property string fallbackType: "disconnected"
  property string fallbackName: "Disconnected"
  property var routes4: []
  property bool routes4Valid: false
  property var route: null

  // Do not enable WifiDevice.scannerEnabled for a passive status indicator.
  onNeedsFallbackChanged: {
    if (needsFallback && active) refresh();
    else { fallbackType = "disconnected"; fallbackName = "Disconnected"; }
  }
  onActiveChanged: if (active && needsFallback) refresh()

  function refresh() {
    if (!ipv4.running && !ipv6.running && !classification.running) ipv4.running = true;
  }
  function parseRoutes(text) {
    try {
      const routes = JSON.parse(text);
      return Array.isArray(routes) ? routes.filter(r => r.dev && !(r.flags || []).includes("linkdown")) : null;
    } catch (e) { return null; }
  }
  function classify(routes, valid) {
    if (!needsFallback) return;
    route = routes[0] ?? null;
    if (!route) {
      fallbackType = valid ? "disconnected" : "unknown";
      fallbackName = valid ? "Disconnected" : "Network unavailable";
    } else {
      classification.scan(["/sys/class/net/" + route.dev]);
    }
  }
  Services.DirectoryScanner {
    id: classification
    onFinished: entries => {
      if (!root.needsFallback || !root.route) return;
      root.fallbackType = entries.some(e => e.name === "wireless") ? "wifi"
        : entries.some(e => e.name === "device") ? "ethernet" : "network";
      const label = root.fallbackType === "wifi" ? "Wi-Fi" : root.fallbackType === "ethernet" ? "Ethernet" : "Connected";
      root.fallbackName = label + " (" + root.route.dev + ")";
    }
  }
  Process {
    id: ipv4
    command: ["ip", "-j", "-4", "route", "show", "default"]
    stdout: StdioCollector { id: output4 }
    onExited: (code, status) => {
      const parsed = root.parseRoutes(output4.text);
      root.routes4Valid = code === 0 && status === 0 && parsed !== null;
      root.routes4 = root.routes4Valid ? parsed : [];
      if (root.needsFallback) ipv6.running = true;
    }
  }
  Process {
    id: ipv6
    command: ["ip", "-j", "-6", "route", "show", "default"]
    stdout: StdioCollector { id: output6 }
    onExited: (code, status) => {
      const parsed = root.parseRoutes(output6.text);
      const valid = code === 0 && status === 0 && parsed !== null;
      root.classify(root.routes4.concat(valid ? parsed : []), root.routes4Valid && valid);
    }
  }
  Timer {
    interval: 15000
    repeat: true
    running: root.active && root.needsFallback
    onTriggered: root.refresh()
  }
}

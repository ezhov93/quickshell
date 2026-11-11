pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.config
import qs.services

Singleton {
  id: root
  property bool active: false
  property string fallbackType: "disconnected"
  property string fallbackName: "Disconnected"
  property list<var> routes4: []
  property bool routes4Valid: false
  property var route: null
  property bool wifiPopoverOpen: false
  property WifiDevice scannerDevice: null
  property bool scannerWasEnabled: false
  property Network pendingNetwork: null
  property string connectionMessage: ""
  property string connectionError: ""
  property bool connectionPending: false

  readonly property var devices: Networking.devices.values
  readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
  readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
  readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
  readonly property var connectedDevice: wired ?? wifi
  readonly property var wifiNetworks: wifiDevice?.networks?.values ?? []
  readonly property var knownNetworks: wifiNetworks.filter(n => n.known)
  readonly property var otherNetworks: wifiNetworks.filter(n => !n.known)
  readonly property WifiNetwork wifiNetwork: wifi?.networks.values.find(n => n.connected) ?? null
  readonly property bool wifiAvailable: wifiDevice !== null
  readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
  readonly property bool wifiEnabled: Networking.wifiEnabled
  readonly property bool needsFallback: !connectedDevice
  readonly property string type: wired ? "ethernet" : wifi ? "wifi" : fallbackType
  readonly property string name: wired ? "Ethernet" : wifi ? (wifiNetwork?.name || "Wi-Fi") : fallbackName

  onNeedsFallbackChanged: {
    if (needsFallback && active) refresh();
    else { fallbackType = "disconnected"; fallbackName = "Disconnected"; }
  }
  onActiveChanged: if (active && needsFallback) refresh()
  onWifiDeviceChanged: {
    if (!wifiPopoverOpen) return;
    releaseWifiScanner();
    acquireWifiScanner();
  }

  DirectoryScanner {
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
    id: networkSettings
    command: Config.networkSettingsCommand
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
    interval: Config.networkFallbackInterval
    repeat: true
    running: root.active && root.needsFallback
    onTriggered: root.refresh()
  }

  Connections {
    target: root.pendingNetwork
    function onStateChanged() { root.handleConnectionState(); }
    function onConnectionFailed(reason) {
      root.failConnection(qsTr("Connection failed: %1").arg(ConnectionFailReason.toString(reason)));
    }
  }
  function openSettings(): void {
    networkSettings.running = true;
  }

  function setWifiEnabled(enabled: bool): void {
    if (wifiHardwareEnabled) Networking.wifiEnabled = enabled;
  }

  function beginWifiPopover(): void {
    if (wifiPopoverOpen) return;
    wifiPopoverOpen = true;
    acquireWifiScanner();
  }

  function endWifiPopover(): void {
    wifiPopoverOpen = false;
    releaseWifiScanner();
    clearConnectionState();
  }

  function acquireWifiScanner(): void {
    if (!wifiDevice || scannerDevice) return;
    scannerDevice = wifiDevice;
    scannerWasEnabled = scannerDevice.scannerEnabled;
    if (!scannerWasEnabled) scannerDevice.scannerEnabled = true;
  }

  function releaseWifiScanner(): void {
    if (scannerDevice && !scannerWasEnabled) scannerDevice.scannerEnabled = false;
    scannerDevice = null;
    scannerWasEnabled = false;
  }

  function clearConnectionState(): void {
    pendingNetwork = null;
    connectionPending = false;
    connectionMessage = "";
    connectionError = "";
  }

  function isPskSecurity(security) {
    return security === WifiSecurityType.Wpa2Psk
      || security === WifiSecurityType.WpaPsk
      || security === WifiSecurityType.Sae;
  }

  function securitySupported(network) {
    return network
      && (network.security === WifiSecurityType.Open || isPskSecurity(network.security));
  }

  function passwordRequired(network) {
    return network && !network.known && isPskSecurity(network.security);
  }

  function securityLabel(network) {
    if (!network) return qsTr("Unknown security");
    if (network.security === WifiSecurityType.Open) return qsTr("Open");
    if (isPskSecurity(network.security)) return qsTr("Password");
    if (network.security === WifiSecurityType.Wpa2Eap
      || network.security === WifiSecurityType.WpaEap) return qsTr("Enterprise");
    return qsTr("Unsupported");
  }

  function connectNetwork(network, psk = "") {
    if (!securitySupported(network)) {
      connectionError = qsTr("This security type is not supported here. Use nmtui.");
      return false;
    }
    if (!network.known && network.security !== WifiSecurityType.Open && psk.length === 0) {
      connectionError = qsTr("A password is required");
      return false;
    }
    if (!network || connectionPending) return false;
    pendingNetwork = network;
    connectionPending = true;
    connectionError = "";
    connectionMessage = qsTr("Connecting to %1…").arg(network.name);
    if (network.security === WifiSecurityType.Open || network.known) network.connect();
    else network.connectWithPsk(psk);
    return true;
  }

  function failConnection(message): void {
    connectionPending = false;
    connectionMessage = "";
    connectionError = message;
    pendingNetwork = null;
  }

  function handleConnectionState() {
    if (pendingNetwork.state === ConnectionState.Connected) {
      connectionPending = false;
      connectionMessage = qsTr("Connected");
      connectionError = "";
      pendingNetwork = null;
    } else if (pendingNetwork.state === ConnectionState.Disconnected && connectionPending) {
      failConnection(qsTr("Connection failed"));
    }
    if (!pendingNetwork) return;
  }

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
    if (!route) {
      fallbackType = valid ? "disconnected" : "unknown";
      fallbackName = valid ? "Disconnected" : "Network unavailable";
    } else {
      classification.scan(["/sys/class/net/" + route.dev]);
    }
    if (!needsFallback) return;
    route = routes[0] ?? null;
  }
  // Do not enable WifiDevice.scannerEnabled for a passive status indicator.
}

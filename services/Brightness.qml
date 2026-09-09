pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
  id: root
  property real value: 0
  property real maximum: 0
  property bool ready: false
  property string device: ""
  property int queuedSteps: 0
  readonly property bool available: ready && maximum > 0
  signal updated()

  function adjust(increase) {
    if (!available) return;
    queuedSteps += increase ? 1 : -1;
    applyQueued();
  }
  function applyQueued() {
    if (setProcess.running || queuedSteps === 0) return;
    const steps = queuedSteps;
    queuedSteps = 0;
    setProcess.command = ["brightnessctl", "--device", device, "set", Math.abs(steps * 5) + "%" + (steps > 0 ? "+" : "-")];
    setProcess.running = true;
  }
  function updateValue() {
    const raw = brightnessFile.text().trim();
    if (raw === "" || !Number.isFinite(Number(raw)) || maximum <= 0) return;
    const next = Math.max(0, Math.min(1, Number(raw) / maximum));
    const changed = ready && next !== value;
    value = next;
    ready = true;
    if (changed) updated();
  }

  DirectoryScanner {
    id: discovery
    onFinished: entries => {
      const entry = entries.find(e => e.isDir);
      root.device = entry?.name ?? "";
    }
  }
  Component.onCompleted: discovery.scan(["/sys/class/backlight"])

  FileView {
    id: maximumFile
    path: root.device ? "/sys/class/backlight/" + root.device + "/max_brightness" : ""
    blockLoading: false
    printErrors: false
    onLoaded: { root.maximum = Number(text().trim()); brightnessFile.reload(); }
    onLoadFailed: { root.maximum = 0; root.ready = false; }
  }
  FileView {
    id: brightnessFile
    path: root.device ? "/sys/class/backlight/" + root.device + "/brightness" : ""
    blockLoading: false
    printErrors: false
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.updateValue()
    onLoadFailed: root.ready = false
  }
  // sysfs does not reliably emit filesystem notifications for external changes.
  Timer {
    interval: Config.brightnessPollInterval
    repeat: true
    running: root.device !== ""
    onTriggered: brightnessFile.reload()
  }
  Process {
    id: setProcess
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0 || exitStatus !== 0) console.warn("Could not change brightness");
      brightnessFile.reload();
      Qt.callLater(root.applyQueued);
    }
  }
}

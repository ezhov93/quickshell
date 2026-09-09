pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config
import qs.services

Singleton {
  id: root
  property bool active: false
  property real cpuUsage: NaN
  property real memoryUsage: NaN
  property real temperature: NaN
  property var previousCpu: null
  property var sensorQueue: []
  property var sensors: []
  property int sensorIndex: 0
  property var candidate: null

  onActiveChanged: {
    previousCpu = null;
    cpuUsage = NaN;
    if (active) {
      cpuFile.reload();
      memoryFile.reload();
      if (temperatureFile.path !== "") temperatureFile.reload();
    }
  }

  function readCpu(text) {
    const line = text.split("\n")[0].trim().split(/\s+/);
    if (line.shift() !== "cpu" || line.length < 4) return NaN;
    // guest and guest_nice are already included in user and nice.
    const values = line.slice(0, 8).map(Number);
    if (values.some(value => !Number.isFinite(value))) return NaN;
    const sample = { total: values.reduce((a, b) => a + b, 0), idle: values[3] + (values[4] || 0) };
    const previous = previousCpu;
    previousCpu = sample;
    if (!previous || sample.total <= previous.total || sample.idle < previous.idle) return NaN;
    return Math.max(0, Math.min(1, 1 - (sample.idle - previous.idle) / (sample.total - previous.total)));
  }

  function readMemory(text) {
    const total = Number(text.match(/^MemTotal:\s+(\d+)/m)?.[1]);
    const available = Number(text.match(/^MemAvailable:\s+(\d+)/m)?.[1]);
    return total > 0 && Number.isFinite(available) ? Math.max(0, Math.min(1, 1 - available / total)) : NaN;
  }

  FileView {
    id: cpuFile
    path: "/proc/stat"
    preload: root.active
    blockLoading: false
    printErrors: false
    onLoaded: root.cpuUsage = root.readCpu(text())
    onLoadFailed: { root.cpuUsage = NaN; root.previousCpu = null; }
  }
  FileView {
    id: memoryFile
    path: "/proc/meminfo"
    preload: root.active
    blockLoading: false
    printErrors: false
    onLoaded: root.memoryUsage = root.readMemory(text())
    onLoadFailed: root.memoryUsage = NaN
  }
  FileView {
    id: temperatureFile
    path: ""
    blockLoading: false
    printErrors: false
    onLoaded: {
      const value = text().trim();
      if (value !== "" && Number.isFinite(Number(value))) root.temperature = Number(value) / 1000;
      else Qt.callLater(root.nextTemperatureSensor);
    }
    onLoadFailed: Qt.callLater(root.nextTemperatureSensor)
  }
  Timer {
    interval: Config.resourceCpuInterval
    running: root.active
    repeat: true
    onTriggered: { cpuFile.reload(); memoryFile.reload(); }
  }
  Timer {
    interval: Config.resourceTemperatureInterval
    running: root.active && temperatureFile.path !== ""
    repeat: true
    onTriggered: temperatureFile.reload()
  }

  DirectoryScanner {
    id: discovery
    onFinished: entries => {
      root.sensorQueue = entries.filter(e => e.isDir && /^(thermal_zone|hwmon)\d+$/.test(e.name));
      root.nextSensor();
    }
  }
  Component.onCompleted: discovery.scan(["/sys/class/thermal", "/sys/class/hwmon"])

  function nextTemperatureSensor() {
    temperature = NaN;
    if (sensorIndex + 1 < sensors.length) {
      sensorIndex++;
      temperatureFile.path = sensors[sensorIndex].path;
    }
  }

  function nextSensor() {
    if (sensorQueue.length === 0) {
      sensors.sort((a, b) => a.priority - b.priority);
      sensorIndex = 0;
      temperatureFile.path = sensors[0]?.path ?? "";
      return;
    }
    candidate = sensorQueue.shift();
    sensorName.path = candidate.path + (candidate.name.startsWith("thermal_zone") ? "/type" : "/name");
  }
  FileView {
    id: sensorName
    blockLoading: false
    printErrors: false
    onLoaded: {
      const names = ["x86_pkg_temp", "cpu-thermal", "cpu_thermal", "TCPU", "coretemp", "k10temp", "zenpower"];
      const priority = names.indexOf(text().trim());
      if (priority >= 0) root.sensors.push({ priority: priority, path: root.candidate.path + (priority < 4 ? "/temp" : "/temp1_input") });
      Qt.callLater(root.nextSensor);
    }
    onLoadFailed: Qt.callLater(root.nextSensor)
  }
}

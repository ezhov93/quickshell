pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string cpuUsage: "0%"
  property string memoryUsage: "0%"
  property string networkInfo: "Disconnected"
  property string networkType: "disconnected"
  property int batteryLevelRaw: 0
  property string batteryLevel: "0%"
  property string batteryIcon: "󰂎"
  property bool batteryCharging: false
  property string temperature: "N/A"

  // CPU Usage
  Process {
    id: cpuProc
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1\"%\"}'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.cpuUsage = text.trim()
      }
    }
  }

  // Memory Usage
  Process {
    id: memProc
    command: ["sh", "-c", "free | grep Mem | awk '{printf \"%.1f%%\", ($3/$2) * 100.0}'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        root.memoryUsage = text.trim()
      }
    }
  }

  // NetworkManager, with a kernel-route fallback for unmanaged interfaces.
  Process {
    id: netProc
    command: ["sh", "-c", "export LC_ALL=C\nif command -v nmcli >/dev/null 2>&1; then\n  devices=$(nmcli -t -f TYPE,STATE device 2>/dev/null)\n  if printf '%s\\n' \"$devices\" | grep -q '^ethernet:connected'; then\n    printf 'ethernet:Ethernet\\n'\n    exit\n  fi\n  wifi=$(nmcli -t --escape no -f ACTIVE,SSID device wifi list --rescan no 2>/dev/null | sed -n 's/^yes://p' | head -n 1)\n  if [ -n \"$wifi\" ]; then\n    printf 'wifi:%s\\n' \"$wifi\"\n    exit\n  fi\nfi\nif ! command -v ip >/dev/null 2>&1; then\n  printf 'unknown:Network unavailable\\n'\n  exit\nfi\nroutes=$(ip -o route show default 2>/dev/null; ip -o -6 route show default 2>/dev/null)\ninterface=$(printf '%s\\n' \"$routes\" | awk '!/linkdown/ {for (i=1;i<NF;i++) if ($i==\"dev\") {print $(i+1); exit}}')\nif [ -z \"$interface\" ]; then\n  printf 'disconnected:Disconnected\\n'\nelif [ -d \"/sys/class/net/$interface/wireless\" ]; then\n  printf 'wifi:Wi-Fi (%s)\\n' \"$interface\"\nelif [ -d \"/sys/class/net/$interface/device\" ]; then\n  printf 'ethernet:Ethernet (%s)\\n' \"$interface\"\nelse\n  printf 'network:Connected (%s)\\n' \"$interface\"\nfi\n"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const result = text.trim()
        const colonIdx = result.indexOf(':')
        const type = result.substring(0, colonIdx)
        const info = result.substring(colonIdx + 1)
        root.networkType = type
        root.networkInfo = info || "Disconnected"
      }
    }
  }

  // Battery
  Process {
    id: batteryProc
    command: ["sh", "-c", "printf '%s\\n%s' \"$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo '99')\" \"$(cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo 'Discharging')\""]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")
        const level = parseInt(lines[0]) || 0
        const status = (lines[1] || "Discharging").trim()

        root.batteryLevelRaw = level
        root.batteryLevel = level + "%"
        root.batteryCharging = status === "Charging"

        if (root.batteryCharging) root.batteryIcon = ""
        else if (level >= 90) root.batteryIcon = "󰁹"
        else if (level >= 80) root.batteryIcon = "󰂂"
        else if (level >= 70) root.batteryIcon = "󰂁"
        else if (level >= 60) root.batteryIcon = "󰂀"
        else if (level >= 50) root.batteryIcon = "󰁿"
        else if (level >= 40) root.batteryIcon = "󰁾"
        else if (level >= 30) root.batteryIcon = "󰁽"
        else if (level >= 20) root.batteryIcon = "󰁼"
        else if (level >= 10) root.batteryIcon = "󰁻"
        else root.batteryIcon = "󰁺"
      }
    }
  }

  // Temperature
  Process {
    id: tempProc
    command: ["sh", "-c", "# Prefer CPU sensors; never substitute battery or Wi-Fi temperatures.\nfor wanted in x86_pkg_temp cpu-thermal cpu_thermal TCPU; do\n  for zone in /sys/class/thermal/thermal_zone*; do\n    [ \"$(cat \"$zone/type\" 2>/dev/null)\" = \"$wanted\" ] || continue\n    value=$(cat \"$zone/temp\" 2>/dev/null) || continue\n    case \"$value\" in ''|*[!0-9-]*) continue ;; esac\n    printf '%s\\n' \"$value\"\n    exit\n  done\ndone\nfor sensor in /sys/class/hwmon/hwmon*; do\n  case \"$(cat \"$sensor/name\" 2>/dev/null)\" in\n    coretemp|k10temp|zenpower)\n      value=$(cat \"$sensor/temp1_input\" 2>/dev/null) || continue\n      case \"$value\" in ''|*[!0-9-]*) continue ;; esac\n      printf '%s\\n' \"$value\"\n      exit\n      ;;\n  esac\ndone\n"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const raw = text.trim();
        const millidegrees = Number(raw);
        root.temperature = raw !== "" && Number.isFinite(millidegrees)
          ? Math.round(millidegrees / 1000) + "°C" : "N/A";
      }
    }
  }

  // Update timer
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      cpuProc.running = true
      memProc.running = true
      netProc.running = true
      batteryProc.running = true
      tempProc.running = true
    }
  }
}

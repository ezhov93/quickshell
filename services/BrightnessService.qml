pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root
  property real value: 0
  property real maximum: 1
  property bool ready: false
  readonly property bool available: brightnessFile.path !== ""
  signal updated()

  function adjust(increase) {
    setProcess.command = ["brightnessctl", "set", increase ? "5%+" : "5%-"];
    setProcess.running = true;
  }

  Process { id: setProcess }

  // Brightness monitoring
  FileView {
    id: brightnessFile
    path: ""
    watchChanges: true
    onFileChanged: brightnessReadProc.running = true
  }

  Process {
    id: brightnessReadProc
    command: ["brightnessctl", "get"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const val = parseInt(text.trim());
        if (!isNaN(val) && root.maximum > 0) {
          root.value = val / root.maximum;
          if (root.ready) root.updated();
          root.ready = true;
        }
      }
    }
  }

  Process {
    id: backlightDiscovery
    command: ["sh", "-c", "p=$(ls -d /sys/class/backlight/*/brightness 2>/dev/null | head -1); [ -n \"$p\" ] && echo \"$p\" && cat \"${p%brightness}max_brightness\""]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n");
        if (lines.length >= 2) {
          const max = parseInt(lines[1]);
          if (!isNaN(max) && max > 0) root.maximum = max;
          brightnessFile.path = lines[0];
          brightnessReadProc.running = true;
        }
      }
    }
  }

}

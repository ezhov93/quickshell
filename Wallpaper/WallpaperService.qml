pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property list<string> wallpapers: []
  property string currentWallpaper: ""
  readonly property string backend: "hyprpaper"
  property string pendingWallpaper: ""
  property int restoreAttempts: 0
  property string applyError: ""

  // Scan wallpaper directories
  Process {
    id: scanner
    command: ["sh", "-c",
      "find ~/Pictures/Wallpapers ~/Pictures -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort -u | head -200"
    ]
    running: false
    stdout: SplitParser {
      onRead: data => {
        const path = data.trim();
        if (path !== "") {
          root.wallpapers = [...root.wallpapers, path];
        }
      }
    }
  }

  // Load saved wallpaper path
  FileView {
    id: configFile
    path: Quickshell.env("HOME") + "/.config/quickshell/wallpaper.conf"
    // No saved wallpaper is normal on the first run.
    printErrors: false
    onLoadFailed: error => {
      if (error !== FileViewError.FileNotFound)
        console.warn("Cannot read wallpaper configuration:", FileViewError.toString(error));
    }
    onLoaded: {
      const saved = configFile.text().trim();
      if (saved !== "") {
        root.pendingWallpaper = saved;
        restoreTimer.start();
      }
    }
  }

  Component.onCompleted: {
    scanner.running = true;
  }

  function rescan() {
    wallpapers = [];
    scanner.running = true;
  }

  function setWallpaper(path, restoring = false) {
    if (setProcess.running || saveProcess.running || path === "") return;
    restoreTimer.stop();
    if (!restoring) restoreAttempts = 0;
    pendingWallpaper = path;
    applyError = "";
    setProcess.command = ["hyprctl", "hyprpaper", "wallpaper", "," + path];
    setProcess.running = true;
  }

  // Hyprpaper may start after Quickshell during session startup.
  Timer {
    id: restoreTimer
    interval: 1000
    onTriggered: {
      root.restoreAttempts++;
      root.setWallpaper(root.pendingWallpaper, true);
    }
  }

  Process {
    id: setProcess
    command: []
    running: false
    stdout: SplitParser {
      onRead: data => { root.applyError += data + "\n"; }
    }
    stderr: SplitParser {
      onRead: data => { root.applyError += data + "\n"; }
    }
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0 || exitStatus !== 0) {
        if (root.restoreAttempts > 0 && root.restoreAttempts < 10) {
          restoreTimer.start();
        } else {
          console.warn("Hyprpaper could not apply wallpaper:", root.pendingWallpaper,
            "exit code:", exitCode, root.applyError.trim());
        }
        return;
      }
      root.restoreAttempts = 0;
      root.currentWallpaper = root.pendingWallpaper;
      saveProcess.command = ["sh", "-c", 'mkdir -p "$HOME/.config/quickshell" && printf "%s" "$1" > "$HOME/.config/quickshell/wallpaper.conf"', "sh", root.currentWallpaper];
      saveProcess.running = true;
    }
  }

  Process {
    id: saveProcess
    command: []
    running: false
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0 || exitStatus !== 0)
        console.warn("Could not save wallpaper configuration");
    }
  }
}

pragma Singleton

import "../../../services" as Services
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

  property bool scanned: false
  property bool saving: false
  Services.DirectoryScanner {
    id: scanner
    onFinished: entries => {
      const paths = entries.filter(e => !e.isDir && /\.(jpg|jpeg|png|webp)$/i.test(e.name)).map(e => e.path);
      root.wallpapers = [...new Set(paths)].sort().slice(0, 200);
      root.scanned = true;
    }
  }

  // Load saved wallpaper path
  FileView {
    id: configFile
    path: Quickshell.env("HOME") + "/.config/quickshell/wallpaper.conf"
    blockLoading: false
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

  Services.TextFileWriter {
    id: configWriter
    onCompleted: (success, error) => {
      root.saving = false;
      if (!success) {
        root.applyError = "Wallpaper applied, but could not save: " + error;
        console.warn(root.applyError);
      }
    }
  }

  function rescan() {
    scanner.scan([Quickshell.env("HOME") + "/Pictures/Wallpapers", Quickshell.env("HOME") + "/Pictures"], 2);
  }

  function setWallpaper(path, restoring = false) {
    if (setProcess.running || root.saving || path === "") return;
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
        if (!root.applyError.trim()) root.applyError = "Hyprpaper failed (exit " + exitCode + ")";
        if (root.restoreAttempts > 0 && root.restoreAttempts < 10) {
          restoreTimer.start();
        } else {
          console.warn("Hyprpaper could not apply wallpaper:", root.pendingWallpaper,
            "exit code:", exitCode, root.applyError.trim());
        }
        return;
      }
      root.restoreAttempts = 0;
      root.applyError = "";
      root.currentWallpaper = root.pendingWallpaper;
      root.saving = true;
      configWriter.write(configFile.path, root.currentWallpaper);
    }
  }

}

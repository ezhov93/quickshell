pragma Singleton

import qs.config
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property list<string> wallpapers: []
  property string currentWallpaper: ""
  readonly property string backend: "hyprpaper"
  property string pendingWallpaper: ""
  property string applyError: ""

  property bool scanned: false
  property bool saving: false
  DirectoryScanner {
    id: scanner
    onFinished: entries => {
      const paths = entries.filter(e => !e.isDir && /\.(jpg|jpeg|png|webp)$/i.test(e.name)).map(e => e.path);
      root.wallpapers = [...new Set(paths)].sort().slice(0, Config.wallpaperMaxCount);
      root.scanned = true;
    }
  }

  function wallpaperBlock(path) {
    return "wallpaper {\n" +
      "    monitor = " + Config.wallpaperMonitor + "\n" +
      "    path = " + path + "\n" +
      "    fit_mode = " + Config.wallpaperFitMode + "\n" +
      "}\n";
  }

  function firstWallpaperBlock(content) {
    const match = /wallpaper\s*\{[\s\S]*?\}/i.exec(content);
    if (!match) return null;
    const pathMatch = /(?:^|\n)\s*path\s*=\s*(.+?)\s*(?:\n|$)/i.exec(match[0]);
    return {
      start: match.index,
      end: match.index + match[0].length,
      path: pathMatch ? pathMatch[1].trim() : ""
    };
  }

  function configWithWallpaper(content, path) {
    const block = firstWallpaperBlock(content);
    const replacement = wallpaperBlock(path);
    if (!block) return content.trim() === "" ? replacement : content.trimEnd() + "\n\n" + replacement;
    return content.slice(0, block.start) + replacement + content.slice(block.end).replace(/^\n*/, "\n");
  }

  function setCurrentWallpaperFromConfig(path) {
    if (!path) return;
    root.currentWallpaper = path;
  }

  function loadSavedWallpaper() {
    setCurrentWallpaperFromConfig(firstWallpaperBlock(configFile.text())?.path || "");
  }

  // Load the saved wallpaper path from hyprpaper.conf.
  FileView {
    id: configFile
    path: Config.wallpaperConfigPath
    blockLoading: false
    // No saved wallpaper is normal on the first run.
    printErrors: false
    onLoadFailed: error => {
      if (error !== FileViewError.FileNotFound)
        console.warn("Cannot read wallpaper configuration:", FileViewError.toString(error));
      root.loadSavedWallpaper();
    }
    onLoaded: {
      root.loadSavedWallpaper();
    }
  }

  TextFileWriter {
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
    scanner.scan(Config.wallpaperDirectories, 2);
  }

  function setWallpaper(path) {
    if (setProcess.running || root.saving || path === "") return;
    pendingWallpaper = path;
    applyError = "";
    setProcess.command = ["hyprctl", "hyprpaper", "wallpaper", "," + path];
    setProcess.running = true;
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
        console.warn("Hyprpaper could not apply wallpaper:", root.pendingWallpaper,
          "exit code:", exitCode, root.applyError.trim());
        return;
      }
      root.applyError = "";
      root.currentWallpaper = root.pendingWallpaper;
      root.saving = true;
      configWriter.write(configFile.path, root.configWithWallpaper(configFile.text(), root.currentWallpaper));
    }
  }

}

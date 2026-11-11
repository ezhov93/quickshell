import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.Wallpaper.components
import qs.modules.Wallpaper.services

Scope {
  id: root
  property Theme theme: Theme
  property string font: Config.fontFamily
  property bool isOpen: false
  IpcHandler {
    target: "wallpaper"
    function toggle(): void {
      root.isOpen = !root.isOpen;
      if (root.isOpen && !WallpaperService.scanned) WallpaperService.rescan();
    }
  }
  LazyLoader {
    active: root.isOpen
    WallpaperWindow {
      theme: root.theme
      font: root.font
      onCloseRequested: root.isOpen = false
    }
  }
}

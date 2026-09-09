import "components"
import "services"
import"../../themes" as Themes
import Quickshell
import Quickshell.Io

Scope {
  id: root
  property var theme: Themes.DefaultTheme
  property string font: "Hack Nerd Font"
  property bool isOpen: false
  // Instantiate the service for restoration, without scanning or creating images.
  readonly property string currentWallpaper: WallpaperService.currentWallpaper

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

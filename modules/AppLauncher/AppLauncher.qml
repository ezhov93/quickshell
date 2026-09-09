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
  // Keep the application index alive when the window is unloaded.
  readonly property var searchIndex: SearchIndex.entries

  IpcHandler {
    target: "launcher"
    function toggle(): void { root.isOpen = !root.isOpen; }
  }
  LazyLoader {
    active: root.isOpen
    LauncherWindow {
      theme: root.theme
      font: root.font
      onCloseRequested: root.isOpen = false
    }
  }
}

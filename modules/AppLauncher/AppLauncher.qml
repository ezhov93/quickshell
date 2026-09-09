import qs.config
import qs.modules.AppLauncher.services
import Quickshell
import Quickshell.Io

Scope {
  id: root
  property var theme: Theme
  property string font: Config.fontFamily
  property bool isOpen: false
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

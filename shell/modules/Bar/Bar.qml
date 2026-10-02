import qs.config
import qs.modules.Bar.components
import qs.modules.Bar.services
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property var theme: Theme
  property string font: Config.fontFamily
  property bool barVisible: true

  Binding { target: ResourceService; property: "active"; value: root.barVisible }
  Binding { target: NetworkService; property: "active"; value: root.barVisible }

  IpcHandler {
    target: "bar"

    function toggle(): void {
      root.barVisible = !root.barVisible;
    }
  }

  Variants {
    model: Quickshell.screens

    BarWindow {
      visible: root.barVisible
      theme: root.theme
      font: root.font
    }
  }
}

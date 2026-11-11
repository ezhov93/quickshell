pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.config

PanelWindow {
  id: root

  required property Theme theme
  property string font: Config.fontFamily

  signal closeRequested()
  signal launchRequested(var entry)

  visible: true
  focusable: true
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore

  WlrLayershell {
    layer: WlrLayer.Overlay
    keyboardFocus: WlrKeyboardFocus.Exclusive
    namespace: "quickshell-launcher"
  }

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.closeRequested()

    Rectangle {
      color: root.theme.bgOverlay
      anchors.fill: parent
    }
  }

  LauncherPanel {
    theme: root.theme
    font: root.font
    anchors.centerIn: parent
    onCloseRequested: root.closeRequested()
    onLaunchRequested: entry => root.launchRequested(entry)
  }
}

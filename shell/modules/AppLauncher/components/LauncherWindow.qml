pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.config

PanelWindow {
  id: root

  required property var theme
  property string font: Config.fontFamily

  signal closeRequested()
  signal launchRequested(var entry)

  visible: true
  focusable: true
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "quickshell-launcher"

  exclusionMode: ExclusionMode.Ignore

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
      anchors.fill: parent
      color: root.theme.bgOverlay
    }
  }

  LauncherPanel {
    anchors.centerIn: parent
    theme: root.theme
    font: root.font
    onCloseRequested: root.closeRequested()
    onLaunchRequested: entry => root.launchRequested(entry)
  }
}

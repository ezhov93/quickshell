import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

Scope {
  id: root
  property Theme theme: Theme
  property string font: Config.fontFamily
  property bool active: false
  property bool showBadge: false

  onActiveChanged: {
    showBadge = true;
    hideTimer.restart();
  }

  Timer {
    id: hideTimer
    interval: 2000
    onTriggered: root.showBadge = false
  }

  IpcHandler {
    target: "idle"

    function toggle(): void {
      root.active = !root.active;
    }

    function enable(): void {
      root.active = true;
    }

    function disable(): void {
      root.active = false;
    }
  }

  PanelWindow {
    id: host
    visible: true
    focusable: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: root.showBadge ? badge : null }
    implicitWidth: 40
    implicitHeight: 40
    margins.bottom: 8
    margins.right: 8

    anchors {
      bottom: true
      right: true
    }

    WlrLayershell {
      layer: WlrLayer.Overlay
      keyboardFocus: WlrKeyboardFocus.None
      namespace: "quickshell-idle-inhibitor"
    }

    IdleInhibitor {
      enabled: root.active
      window: host
    }

    Rectangle {
      id: badge
      width: 32
      height: 32
      radius: 16
      color: root.theme.bgBase
      opacity: root.showBadge ? 1 : 0

      anchors.centerIn: parent
      border.color: root.active ? root.theme.accentOrange : root.theme.bgBorder
      border.width: 1
      Accessible.role: Accessible.Indicator
      Accessible.name: root.active ? "Idle inhibitor active — screen will not sleep" : "Idle inhibitor inactive — normal sleep behavior"

      Behavior on border.color { ColorAnimation { duration: 150 } }
      Behavior on opacity { NumberAnimation { duration: 150 } }

      Text {
        text: root.active ? "" : ""
        color: root.active ? root.theme.accentOrange : root.theme.textMuted
        anchors.centerIn: parent
        font.pixelSize: 16
        font.family: root.font
      }

      MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: root.active = !root.active
      }
    }
    // Always mapped — the Wayland idle inhibitor only holds while this
    // window stays mapped, so this must never be tied to `root.active`.
  }
}

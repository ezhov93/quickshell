import QtQuick
import Quickshell.Hyprland

Row {
  id: root
  required property var theme
  required property string font

  spacing: 4

  Repeater {
    model: Hyprland.workspaces

    Rectangle {
      id: wsPill
      required property var modelData
      property bool urgentBlink: false

      Accessible.role: Accessible.Button
      Accessible.name: "Workspace " + modelData.id + (modelData.focused ? ", active" : "") + (modelData.urgent ? ", urgent" : "")

      width: modelData.focused ? 32 : 24
      height: 24
      radius: 12
      color: modelData.focused ? root.theme.accentPrimary :
             modelData.urgent && urgentBlink ? root.theme.accentRed : root.theme.bgSurface

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      SequentialAnimation {
        loops: Animation.Infinite
        running: wsPill.modelData.urgent && !wsPill.modelData.focused

        PropertyAction { target: wsPill; property: "urgentBlink"; value: true }
        PauseAnimation { duration: 500 }
        PropertyAction { target: wsPill; property: "urgentBlink"; value: false }
        PauseAnimation { duration: 500 }

        onStopped: wsPill.urgentBlink = false
      }

      Text {
        anchors.centerIn: parent
        text: wsPill.modelData.id
        color: wsPill.modelData.focused ? root.theme.bgBase : root.theme.textPrimary
        font.pixelSize: 11
        font.family: root.font
        font.bold: wsPill.modelData.focused
      }

      MouseArea {
        anchors.fill: parent
        onClicked: wsPill.modelData.activate()
      }

      Behavior on width {
        NumberAnimation { duration: 150 }
      }
    }
  }
}

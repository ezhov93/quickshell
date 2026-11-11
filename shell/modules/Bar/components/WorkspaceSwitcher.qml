import QtQuick
import Quickshell.Hyprland
import qs.config
import qs.modules.Bar.services

Row {
  id: root

  required property Theme theme
  required property string font

  spacing: 4

  Repeater {
    model: WorkspaceService.workspaces

    BarButton {
      id: workspaceButton

      required property HyprlandWorkspace modelData
      property bool urgentBlink: false

      theme: root.theme
      font: root.font
      width: modelData.focused ? 32 : 24
      horizontalPadding: 0
      baseColor: modelData.focused
        ? root.theme.accentPrimary
        : modelData.urgent && urgentBlink ? root.theme.accentRed : root.theme.bgSurface
      hoverColor: modelData.focused ? root.theme.accentPrimary : root.theme.bgHover
      Accessible.name: qsTr("Workspace %1%2%3")
        .arg(modelData.id)
        .arg(modelData.focused ? qsTr(", active") : "")
        .arg(modelData.urgent ? qsTr(", urgent") : "")
      onClicked: WorkspaceService.activateWorkspace(workspaceButton.modelData)

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      SequentialAnimation {
        loops: Animation.Infinite
        running: workspaceButton.modelData.urgent && !workspaceButton.modelData.focused

        onStopped: workspaceButton.urgentBlink = false
        PropertyAction { target: workspaceButton; property: "urgentBlink"; value: true }
        PauseAnimation { duration: 500 }
        PropertyAction { target: workspaceButton; property: "urgentBlink"; value: false }
        PauseAnimation { duration: 500 }

      }

      Text {
        text: workspaceButton.modelData.id
        color: workspaceButton.modelData.focused ? root.theme.bgBase : root.theme.textPrimary
        anchors.centerIn: parent
        font {
          pixelSize: 11
          family: root.font
          bold: workspaceButton.modelData.focused
        }
      }

      Behavior on width {
        NumberAnimation { duration: 150 }
      }
    }
  }
}

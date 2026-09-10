import QtQuick
import qs.modules.Bar.services

Row {
  id: listRoot
  required property var theme
  required property string font

  spacing: 4

  Repeater {
    model: WorkspaceService.workspaces

    BarButton {
      id: wsPill
      required property var modelData
      property bool urgentBlink: false
      theme: listRoot.theme
      font: listRoot.font

      Accessible.role: Accessible.Button
      Accessible.name: "Workspace " + modelData.id + (modelData.focused ? ", active" : "") + (modelData.urgent ? ", urgent" : "")

      width: modelData.focused ? 32 : 24
      horizontalPadding: 0
      interactive: true
      baseColor: modelData.focused ? listRoot.theme.accentPrimary :
                  modelData.urgent && urgentBlink ? listRoot.theme.accentRed : listRoot.theme.bgSurface
      hoverColor: modelData.focused ? listRoot.theme.accentPrimary : listRoot.theme.bgHover

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
        color: wsPill.modelData.focused ? listRoot.theme.bgBase : listRoot.theme.textPrimary
        font.pixelSize: 11
        font.family: listRoot.font
        font.bold: wsPill.modelData.focused
      }

      onClicked: WorkspaceService.activateWorkspace(wsPill.modelData)

      Behavior on width {
        NumberAnimation { duration: 150 }
      }
    }
  }
}

import QtQuick
import qs.modules.Bar.services

Item {
  id: root

  required property var theme
  required property string font

  Text {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(0, Math.min(implicitWidth, parent.width))
    text: WorkspaceService.activeWindowTitle
    color: root.theme.textPrimary
    font.pixelSize: 13
    font.family: root.font
    elide: Text.ElideRight
    Accessible.role: Accessible.StaticText
    Accessible.name: qsTr("Active window: %1").arg(text)
  }
}

import QtQuick
import qs.config
import qs.modules.Bar.services

Item {
  id: root

  required property Theme theme
  required property string font

  Text {
    width: Math.max(0, Math.min(implicitWidth, parent.width))
    text: WorkspaceService.activeWindowTitle
    color: root.theme.textPrimary
    elide: Text.ElideRight
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: 13
    font.family: root.font
    Accessible.role: Accessible.StaticText
    Accessible.name: qsTr("Active window: %1").arg(text)
  }
}

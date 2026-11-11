import QtQuick
import qs.services

BarButton {
  id: root
  width: brightContent.width + 12
  visible: Brightness.available

  Accessible.role: Accessible.StaticText
  Accessible.name: "Brightness: " + Math.round(Brightness.value * 100) + "%"
  onWheelUp: Brightness.adjust(true)
  onWheelDown: Brightness.adjust(false)

  Row {
    id: brightContent
    spacing: 6

    anchors.centerIn: parent
    Text {
      text: "󰃠"
      color: root.theme.accentOrange
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      text: Math.round(Brightness.value * 100) + "%"
      color: root.theme.textPrimary
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 11
      font.family: root.font
    }
  }

}

import qs.services
import QtQuick

BarButton {
  id: root
  width: brightContent.width + 12
  visible: Brightness.available

  Accessible.role: Accessible.StaticText
  Accessible.name: "Brightness: " + Math.round(Brightness.value * 100) + "%"

  Row {
    id: brightContent
    anchors.centerIn: parent
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "󰃠"
      color: root.theme.accentOrange
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Math.round(Brightness.value * 100) + "%"
      color: root.theme.textPrimary
      font.pixelSize: 11
      font.family: root.font
    }
  }

  onWheelUp: Brightness.adjust(true)
  onWheelDown: Brightness.adjust(false)
}

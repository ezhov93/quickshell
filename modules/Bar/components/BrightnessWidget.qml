import qs.services
import QtQuick

Rectangle {
  id: root
  required property var theme
  required property string font

  height: 24
  width: brightContent.width + 12
  radius: 12
  color: root.theme.bgSurface
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

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onWheel: (wheel) => {
      Brightness.adjust(wheel.angleDelta.y > 0);
    }
  }
}

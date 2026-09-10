import QtQuick
import qs.modules.Bar.services

Rectangle {
  id: root
  required property var theme
  required property string font
  height: 24
  width: nowPlayingContent.width + 16
  radius: 12
  color: root.theme.bgSurface
  visible: MediaService.available

  Accessible.role: Accessible.Button
  Accessible.name: MediaService.accessibleText

  Row {
    id: nowPlayingContent
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: 8
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: MediaService.isPlaying ? "󰐊" : "󰏤"
      color: root.theme.accentPrimary
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: MediaService.displayText
      color: root.theme.textPrimary
      font.pixelSize: 11
      font.family: root.font
      elide: Text.ElideRight
      width: Math.min(implicitWidth, 200)
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: MediaService.togglePlayback()
  }
}

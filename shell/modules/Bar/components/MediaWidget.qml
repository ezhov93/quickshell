import QtQuick
import qs.modules.Bar.services

BarButton {
  id: root
  width: nowPlayingContent.width + 16
  visible: MediaService.available

  Accessible.role: Accessible.Button
  Accessible.name: MediaService.accessibleText
  onClicked: MediaService.togglePlayback()

  Row {
    id: nowPlayingContent
    spacing: 6
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: 8
    }

    Text {
      text: MediaService.isPlaying ? "󰐊" : "󰏤"
      color: root.theme.accentPrimary
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      text: MediaService.displayText
      color: root.theme.textPrimary
      elide: Text.ElideRight
      width: Math.min(implicitWidth, 200)
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 11
      font.family: root.font
    }
  }

}

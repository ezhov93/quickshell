import QtQuick
import qs.services

BarButton {
  id: root
  width: volContent.width + 12

  Accessible.role: Accessible.StaticText
  Accessible.name: {
    const sink = Audio.sink;
    if (!sink || !sink.audio) return "Volume";
    if (sink.audio.muted) return "Volume: muted";
    return "Volume: " + Math.round(sink.audio.volume * 100) + "%";
  }
  onClicked: Audio.toggleMute()
  onWheelUp: Audio.adjust(true)
  onWheelDown: Audio.adjust(false)

  Row {
    id: volContent
    spacing: 6

    anchors.centerIn: parent
    Text {
      text: {
        const sink = Audio.sink;
        if (!sink || !sink.audio || sink.audio.muted || sink.audio.volume <= 0) return "󰖁";
        if (sink.audio.volume < 0.33) return "󰕿";
        if (sink.audio.volume < 0.66) return "󰖀";
        return "󰕾";
      }
      color: {
        const sink = Audio.sink;
        if (!sink || !sink.audio || sink.audio.muted) return root.theme.textMuted;
        return root.theme.accentPrimary;
      }
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      text: {
        const sink = Audio.sink;
        if (!sink || !sink.audio) return "–";
        if (sink.audio.muted) return "Mute";
        return Math.round(sink.audio.volume * 100) + "%";
      }
      color: root.theme.textPrimary
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 11
      font.family: root.font
    }
  }

}

import QtQuick
import Quickshell.Services.Pipewire

Rectangle {
  id: root
  required property var theme
  required property string font
  PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

  height: 24
  width: volContent.width + 12
  radius: 12
  color: root.theme.bgSurface

  Accessible.role: Accessible.StaticText
  Accessible.name: {
    const sink = Pipewire.defaultAudioSink;
    if (!sink || !sink.audio) return "Volume";
    if (sink.audio.muted) return "Volume: muted";
    return "Volume: " + Math.round(sink.audio.volume * 100) + "%";
  }

  Row {
    id: volContent
    anchors.centerIn: parent
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: {
        const sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio || sink.audio.muted || sink.audio.volume <= 0) return "󰖁";
        if (sink.audio.volume < 0.33) return "󰕿";
        if (sink.audio.volume < 0.66) return "󰖀";
        return "󰕾";
      }
      color: {
        const sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio || sink.audio.muted) return root.theme.textMuted;
        return root.theme.accentPrimary;
      }
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: {
        const sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio) return "–";
        if (sink.audio.muted) return "Mute";
        return Math.round(sink.audio.volume * 100) + "%";
      }
      color: root.theme.textPrimary
      font.pixelSize: 11
      font.family: root.font
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton
    onClicked: {
      const sink = Pipewire.defaultAudioSink;
      if (sink && sink.audio) sink.audio.muted = !sink.audio.muted;
    }
    onWheel: (wheel) => {
      const sink = Pipewire.defaultAudioSink;
      if (!sink || !sink.audio) return;
      const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
      sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta));
    }
  }
}

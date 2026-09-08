import QtQuick
import Quickshell.Services.Mpris

Rectangle {
  id: root
  required property var theme
  required property string font
  // MPRIS active player
  property var activePlayer: {
    const players = Mpris.players.values;
    if (!players || players.length === 0) return null;
    for (const p of players) {
      if (p.playbackState === MprisPlaybackState.Playing) return p;
    }
    return players[0];
  }

  height: 24
  width: nowPlayingContent.width + 16
  radius: 12
  color: root.theme.bgSurface
  visible: root.activePlayer !== null

  Accessible.role: Accessible.Button
  Accessible.name: {
    if (!root.activePlayer) return "No media";
    const artist = root.activePlayer.trackArtist || "";
    const title = root.activePlayer.trackTitle || "";
    return "Now playing: " + (artist ? artist + " - " : "") + title;
  }

  Row {
    id: nowPlayingContent
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: 8
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.activePlayer && root.activePlayer.isPlaying ? "󰐊" : "󰏤"
      color: root.theme.accentPrimary
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: {
        if (!root.activePlayer) return "";
        const artist = root.activePlayer.trackArtist || "";
        const title = root.activePlayer.trackTitle || "";
        return artist ? artist + " - " + title : title;
      }
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
    onClicked: root.activePlayer.togglePlaying()
  }
}

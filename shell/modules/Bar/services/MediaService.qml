pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
  readonly property var activePlayer: {
    const players = Mpris.players.values;
    if (!players || players.length === 0) return null;
    for (const player of players) {
      if (player.playbackState === MprisPlaybackState.Playing) return player;
    }
    return players[0];
  }
  readonly property bool available: activePlayer !== null
  readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false
  readonly property string artist: activePlayer ? (activePlayer.trackArtist || "") : ""
  readonly property string title: activePlayer ? (activePlayer.trackTitle || "") : ""
  readonly property string displayText: artist ? artist + " - " + title : title
  readonly property string accessibleText: available ? "Now playing: " + displayText : "No media"

  function togglePlayback(): void {
    if (activePlayer) activePlayer.togglePlaying();
  }
}

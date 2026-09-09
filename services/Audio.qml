pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
  id: root
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var audio: sink?.audio ?? null
  readonly property bool available: audio !== null
  readonly property real volume: audio?.volume ?? 0
  readonly property bool muted: audio?.muted ?? false

  PwObjectTracker { objects: root.sink ? [root.sink] : [] }

  function adjust(increase) {
    if (audio) audio.volume = Math.max(0, Math.min(1.5, volume + (increase ? 0.05 : -0.05)));
  }
  function toggleMute() {
    if (audio) audio.muted = !muted;
  }
}

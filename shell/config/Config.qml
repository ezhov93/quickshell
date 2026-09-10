pragma Singleton

import QtQuick
import Quickshell

QtObject {
  readonly property string fontFamily: "Hack Nerd Font"
  readonly property list<string> networkSettingsCommand: ["foot", "--app-id=lpde-nmtui", "-o", "main.pad=0x0", "-e", "nmtui"]

  readonly property int resourceCpuInterval: 2000
  readonly property int resourceTemperatureInterval: 5000
  readonly property int networkFallbackInterval: 15000
  readonly property int brightnessPollInterval: 2000

  readonly property list<string> wallpaperDirectories: [
    Quickshell.env("HOME") + "/Pictures/Wallpapers",
    Quickshell.env("HOME") + "/Pictures"
  ]
  readonly property string wallpaperConfigPath: Quickshell.env("HOME") + "/.config/quickshell/wallpaper.conf"
  readonly property int wallpaperMaxCount: 200

  readonly property int notificationMaxCount: 5
  readonly property int notificationDefaultTimeout: 5000

  readonly property string monitorConfigDirectory: Quickshell.env("HOME") + "/.config/hypr"
  readonly property int monitorRefreshDebounce: 250
  readonly property int monitorExternalPollInterval: 3000
  readonly property int monitorApplyVerifyTimeout: 3000
}

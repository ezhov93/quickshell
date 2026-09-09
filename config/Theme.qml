pragma Singleton

import QtQuick

// Nordic GTK / Nord palette: https://github.com/EliverLara/Nordic
QtObject {
  readonly property color bgBase: "#2e3440"
  readonly property color bgSurface: "#3b4252"
  readonly property color bgOverlay: "#88000000"
  readonly property color bgHover: "#434c5e"
  // Keep selected surfaces dark for the light text used by existing widgets.
  readonly property color bgSelected: "#4c566a"
  readonly property color bgBorder: "#232831"

  readonly property color textPrimary: "#d8dee9"
  readonly property color textSecondary: "#b9bfcb"
  readonly property color textMuted: "#8e95a4"

  readonly property color accentPrimary: "#8fbcbb"
  readonly property color accentCyan: "#88c0d0"
  readonly property color accentGreen: "#a3be8c"
  readonly property color accentOrange: "#d08770"
  readonly property color accentRed: "#bf616a"

  readonly property color urgencyLow: textMuted
  readonly property color urgencyNormal: accentPrimary
  readonly property color urgencyCritical: accentRed
  readonly property color batteryGood: accentGreen
  readonly property color batteryWarning: accentOrange
  readonly property color batteryCritical: accentRed

}

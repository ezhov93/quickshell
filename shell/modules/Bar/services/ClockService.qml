pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
  readonly property string timeString: Qt.formatDateTime(clock.date, "hh:mm")
  readonly property string timeWithSecondsString: Qt.formatDateTime(clock.date, "hh:mm:ss")
  readonly property string dateString: Qt.formatDateTime(clock.date, "ddd MMM d")
  readonly property int currentYear: clock.date.getFullYear()
  readonly property int currentMonth: clock.date.getMonth()
  readonly property int currentDay: clock.date.getDate()

}

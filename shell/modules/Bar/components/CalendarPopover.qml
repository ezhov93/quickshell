import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import qs.modules.Bar.services
import qs.config

pragma ComponentBehavior: Bound

PopupWindow {
  id: root

  required property Item anchorItem
  required property Theme theme
  required property string font
  property int displayYear: ClockService.currentYear
  property int displayMonth: ClockService.currentMonth
  property var calendarLocale: Qt.locale()
  property bool closeSignalSent: false

  signal closedByUser()

  visible: false
  grabFocus: true
  color: "transparent"
  implicitWidth: 300
  implicitHeight: 372

  onVisibleChanged: {
    if (visible) {
      closeSignalSent = false;
      showToday();
      previousButton.forceActiveFocus();
    } else {
      emitClosedByUser();
    }
  }
  onClosed: emitClosedByUser()

  anchor {
    item: anchorItem
    edges: Edges.Bottom | Edges.Right
    gravity: Edges.Bottom | Edges.Left
    adjustment: PopupAdjustment.All
  }

  Rectangle {
    id: panel
    color: root.theme.bgBase
    radius: 10
    activeFocusOnTab: true

    anchors.fill: parent
    border.color: root.theme.bgBorder
    border.width: 1
    Keys.onEscapePressed: event => {
      root.closePopover();
      event.accepted = true;
    }

    ColumnLayout {
      spacing: 8

      anchors.fill: parent
      anchors.margins: 12
      Text {
        text: ClockService.timeWithSecondsString
        color: root.theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        Accessible.role: Accessible.StaticText
        Accessible.name: qsTr("Current time: %1").arg(text)
        font {
          family: root.font
          pixelSize: 32
          bold: true
        }
      }

      RowLayout {
        spacing: 6

        Layout.fillWidth: true
        Text {
          text: root.monthTitle
          color: root.theme.textPrimary
          elide: Text.ElideRight
          Layout.fillWidth: true
          font {
            family: root.font
            pixelSize: 15
            bold: true
          }
        }

        CalendarHeaderButton {
          id: previousButton
          theme: root.theme
          fontFamily: root.font
          text: "‹"
          Accessible.name: qsTr("Previous month")
          KeyNavigation.tab: todayButton
          KeyNavigation.backtab: nextButton
          KeyNavigation.priority: KeyNavigation.BeforeItem
          onClicked: root.changeMonth(-1)
        }

        CalendarHeaderButton {
          id: todayButton
          theme: root.theme
          fontFamily: root.font
          text: qsTr("Today")
          Accessible.name: qsTr("Show current month")
          KeyNavigation.tab: nextButton
          KeyNavigation.backtab: previousButton
          KeyNavigation.priority: KeyNavigation.BeforeItem
          onClicked: root.showToday()
        }

        CalendarHeaderButton {
          id: nextButton
          theme: root.theme
          fontFamily: root.font
          text: "›"
          Accessible.name: qsTr("Next month")
          KeyNavigation.tab: previousButton
          KeyNavigation.backtab: todayButton
          KeyNavigation.priority: KeyNavigation.BeforeItem
          onClicked: root.changeMonth(1)
        }
      }

      DayOfWeekRow {
        id: weekHeader
        locale: root.mondayFirstLocale
        spacing: 4

        delegate: Text {
          required property int day

          width: (weekHeader.availableWidth - weekHeader.spacing * 6) / 7
          height: 24
          text: root.calendarLocale.dayName(day, Locale.ShortFormat)
          color: root.theme.textMuted
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          font.family: root.font
          font.pixelSize: 11
        }
        Layout.fillWidth: true
        Layout.preferredHeight: 24
      }

      MonthGrid {
        id: monthGrid
        month: root.displayMonth
        year: root.displayYear
        locale: root.mondayFirstLocale
        spacing: 4
        enabled: false

        delegate: Rectangle {
          required property var model
          width: (monthGrid.availableWidth - monthGrid.spacing * 6) / 7
          height: (monthGrid.availableHeight - monthGrid.spacing * 5) / 6
          color: isToday ? root.theme.accentPrimary : "transparent"
          radius: Math.min(width, height) / 2

          Text {
            text: model.day
            color: parent.isToday
              ? root.theme.bgBase
              : parent.inCurrentMonth ? root.theme.textPrimary : root.theme.textMuted
          font {
            family: root.font
            pixelSize: 12
            bold: parent.isToday
          }
            anchors.centerIn: parent
          }
          readonly property bool inCurrentMonth: model.month === monthGrid.month
          readonly property bool isToday: model.year === ClockService.currentYear
            && model.month === ClockService.currentMonth
            && model.day === ClockService.currentDay

        }
        Layout.fillWidth: true
        Layout.fillHeight: true
      }
    }
  }
  function emitClosedByUser() {
    if (closeSignalSent) return;
    closeSignalSent = true;
    closedByUser();
  }

  function closePopover() {
    closedByUser();
  }

  function showToday() {
    displayYear = ClockService.currentYear;
    displayMonth = ClockService.currentMonth;
  }

  function changeMonth(offset) {
    const month = new Date(displayYear, displayMonth + offset, 1);
    displayYear = month.getFullYear();
    displayMonth = month.getMonth();
  }

  readonly property var mondayFirstLocale: Qt.locale("en_GB")
  readonly property string monthTitle: qsTr("%1 %2")
    .arg(root.calendarLocale.standaloneMonthName(root.displayMonth + 1, Locale.LongFormat))
    .arg(root.displayYear)
}

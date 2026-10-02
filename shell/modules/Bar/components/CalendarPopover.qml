import Quickshell
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import qs.modules.Bar.services

PopupWindow {
  id: root

  required property var anchorItem
  required property var theme
  required property string font
  property int displayYear: ClockService.currentYear
  property int displayMonth: ClockService.currentMonth
  property var calendarLocale: Qt.locale()
  readonly property var mondayFirstLocale: Qt.locale("en_GB")
  readonly property string monthTitle: qsTr("%1 %2")
    .arg(root.calendarLocale.standaloneMonthName(root.displayMonth + 1, Locale.LongFormat))
    .arg(root.displayYear)

  signal closedByUser()

  visible: false
  grabFocus: true
  color: "transparent"
  implicitWidth: 300
  implicitHeight: 372

  anchor.item: anchorItem
  anchor.edges: Edges.Bottom | Edges.Right
  anchor.gravity: Edges.Bottom | Edges.Left
  anchor.adjustment: PopupAdjustment.All

  onVisibleChanged: {
    if (visible) {
      showToday();
      previousButton.forceActiveFocus();
    } else {
      closedByUser();
    }
  }
  onClosed: closedByUser()

  function closePopover() {
    visible = false;
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

  Rectangle {
    id: panel
    anchors.fill: parent
    color: root.theme.bgBase
    border.color: root.theme.bgBorder
    border.width: 1
    radius: 10
    activeFocusOnTab: true

    Keys.onEscapePressed: event => {
      root.closePopover();
      event.accepted = true;
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8

      Text {
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        text: ClockService.timeWithSecondsString
        color: root.theme.textPrimary
        font.family: root.font
        font.pixelSize: 32
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Accessible.role: Accessible.StaticText
        Accessible.name: qsTr("Current time: %1").arg(text)
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
          Layout.fillWidth: true
          text: root.monthTitle
          color: root.theme.textPrimary
          font.family: root.font
          font.pixelSize: 15
          font.bold: true
          elide: Text.ElideRight
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
        Layout.fillWidth: true
        Layout.preferredHeight: 24
        locale: root.mondayFirstLocale
        spacing: 4

        delegate: Text {
          required property int day

          width: (weekHeader.availableWidth - weekHeader.spacing * 6) / 7
          height: 24
          text: root.calendarLocale.dayName(day, Locale.ShortFormat)
          color: root.theme.textMuted
          font.family: root.font
          font.pixelSize: 11
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
      }

      MonthGrid {
        id: monthGrid
        Layout.fillWidth: true
        Layout.fillHeight: true
        month: root.displayMonth
        year: root.displayYear
        locale: root.mondayFirstLocale
        spacing: 4
        enabled: false

        delegate: Rectangle {
          required property var model
          readonly property bool inCurrentMonth: model.month === monthGrid.month
          readonly property bool isToday: model.year === ClockService.currentYear
            && model.month === ClockService.currentMonth
            && model.day === ClockService.currentDay

          width: (monthGrid.availableWidth - monthGrid.spacing * 6) / 7
          height: (monthGrid.availableHeight - monthGrid.spacing * 5) / 6
          color: isToday ? root.theme.accentPrimary : "transparent"
          radius: Math.min(width, height) / 2

          Text {
            anchors.centerIn: parent
            text: model.day
            color: parent.isToday
              ? root.theme.bgBase
              : parent.inCurrentMonth ? root.theme.textPrimary : root.theme.textMuted
            font.family: root.font
            font.pixelSize: 12
            font.bold: parent.isToday
          }
        }
      }
    }
  }
}

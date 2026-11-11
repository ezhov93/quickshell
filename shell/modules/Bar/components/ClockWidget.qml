import QtQuick
import Quickshell
import qs.modules.Bar.services

BarButton {
  id: root
  property bool calendarOpen: false

  width: content.width + 16
  Accessible.name: qsTr("Date: %1, time: %2").arg(ClockService.dateString).arg(ClockService.timeString)
  Accessible.description: root.calendarOpen ? qsTr("Close calendar") : qsTr("Open calendar")
  onClicked: root.calendarOpen = !root.calendarOpen

  Row {
    id: content
    spacing: 8

    anchors.centerIn: parent
    Text {
      text: ""
      color: root.theme.accentPrimary
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      text: ClockService.dateString
      color: root.theme.textPrimary
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 12
      font.family: root.font
    }

    Text {
      text: ClockService.timeString
      color: root.theme.textSecondary
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 12
      font.family: root.font
    }
  }

  LazyLoader {
    active: root.calendarOpen

    component: CalendarPopover {
      anchorItem: root
      theme: root.theme
      font: root.font
      visible: root.calendarOpen
      onClosedByUser: root.calendarOpen = false
    }
  }
}

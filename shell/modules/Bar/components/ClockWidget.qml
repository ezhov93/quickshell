import QtQuick
import Quickshell
import qs.modules.Bar.services

BarButton {
  id: root
  property bool calendarOpen: false

  width: content.width + 16
  Accessible.name: qsTr("Date: %1, time: %2").arg(ClockService.dateString).arg(ClockService.timeString)
  Accessible.description: root.calendarOpen ? qsTr("Close calendar") : qsTr("Open calendar")

  Row {
    id: content
    anchors.centerIn: parent
    spacing: 8

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: ""
      color: root.theme.accentPrimary
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: ClockService.dateString
      color: root.theme.textPrimary
      font.pixelSize: 12
      font.family: root.font
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: ClockService.timeString
      color: root.theme.textSecondary
      font.pixelSize: 12
      font.family: root.font
    }
  }

  onClicked: root.calendarOpen = !root.calendarOpen

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

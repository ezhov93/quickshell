pragma ComponentBehavior: Bound

import QtQuick

ListView {
  id: root

  required property var theme
  required property string font
  required property var entriesModel
  required property int selectedIndex
  required property string query

  signal activated(var entry)
  signal hovered(int index)

  model: root.entriesModel
  clip: true
  spacing: 2
  boundsBehavior: Flickable.StopAtBounds
  currentIndex: root.selectedIndex
  highlightMoveDuration: 150
  highlightMoveVelocity: -1

  highlight: Rectangle {
    radius: 8
    color: root.theme.bgSelected
    visible: root.selectedIndex >= 0

    Rectangle {
      width: 3
      height: 24
      radius: 2
      color: root.theme.accentPrimary
      anchors {
        left: parent.left
        leftMargin: 2
        verticalCenter: parent.verticalCenter
      }
    }
  }

  delegate: LauncherEntry {
    required property var modelData
    required property int index

    width: root.width
    height: implicitHeight
    entry: modelData
    entryIndex: index
    selected: root.selectedIndex === index
    theme: root.theme
    font: root.font
    onActivated: entry => root.activated(entry)
    onHovered: index => root.hovered(index)
  }

  Text {
    anchors.centerIn: parent
    text: "  No applications found"
    color: root.theme.textMuted
    font.pixelSize: 14
    font.family: root.font
    visible: root.count === 0 && root.query !== ""
  }

  function positionSelected(index): void {
    if (index >= 0 && index < root.count)
      root.positionViewAtIndex(index, ListView.Contain);
  }
}

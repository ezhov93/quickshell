import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
  id: root

  required property var theme
  required property string font
  required property var entry
  required property int entryIndex
  required property bool selected

  signal activated(var entry)
  signal hovered(int index)

  implicitHeight: 44

  Accessible.role: Accessible.Button
  Accessible.name: (root.entry.name ?? "Application")
                   + (root.entry.genericName ? " - " + root.entry.genericName : "")

  RowLayout {
    anchors {
      fill: parent
      leftMargin: 12
      rightMargin: 12
    }
    spacing: 12

    Item {
      Layout.preferredWidth: 28
      Layout.preferredHeight: 28
      Layout.alignment: Qt.AlignVCenter

      IconImage {
        id: appIcon
        anchors.fill: parent
        implicitSize: 28
        source: Quickshell.iconPath(root.entry.icon ?? "", true)
        visible: (root.entry.icon ?? "") !== ""
      }

      Text {
        anchors.centerIn: parent
        text: "▥"
        textFormat: Text.PlainText
        color: root.theme.accentPrimary
        font.pixelSize: 20
        font.family: root.font
        visible: appIcon.source === "" || appIcon.status === Image.Error
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 1

      Text {
        Layout.fillWidth: true
        text: root.entry.name ?? ""
        textFormat: Text.PlainText
        color: root.selected ? root.theme.textPrimary : root.theme.textSecondary
        font.pixelSize: 13
        font.family: root.font
        font.bold: root.selected
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        text: root.entry.genericName ?? root.entry.comment ?? ""
        textFormat: Text.PlainText
        color: root.theme.textMuted
        font.pixelSize: 11
        font.family: root.font
        elide: Text.ElideRight
        visible: text !== ""
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.activated(root.entry)
    onPositionChanged: root.hovered(root.entryIndex)
  }
}

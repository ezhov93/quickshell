import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config

Item {
  id: root

  required property Theme theme
  required property string font
  required property DesktopEntry entry
  required property int entryIndex
  required property bool selected

  signal activated(var entry)
  signal hovered(int index)

  implicitHeight: 44

  Accessible.role: Accessible.Button
  Accessible.name: (root.entry.name ?? "Application")
                   + (root.entry.genericName ? " - " + root.entry.genericName : "")

  RowLayout {
    spacing: 12
    anchors {
      fill: parent
      leftMargin: 12
      rightMargin: 12
    }
    Item {
      Layout.preferredWidth: 28
      Layout.preferredHeight: 28
      Layout.alignment: Qt.AlignVCenter

      IconImage {
        id: appIcon
        implicitSize: 28
        source: Quickshell.iconPath(root.entry.icon ?? "", true)
        visible: (root.entry.icon ?? "") !== ""
        anchors.centerIn: parent
      }

      Text {
        text: "▥"
        textFormat: Text.PlainText
        color: root.theme.accentPrimary
        visible: appIcon.source === "" || appIcon.status === Image.Error
        anchors.centerIn: parent
        font.pixelSize: 20
        font.family: root.font
      }
    }

    ColumnLayout {
      spacing: 1
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter

      Text {
        text: root.entry.name ?? ""
        textFormat: Text.PlainText
        color: root.selected ? root.theme.textPrimary : root.theme.textSecondary
        elide: Text.ElideRight
        Layout.fillWidth: true
        font {
          pixelSize: 13
          family: root.font
          bold: root.selected
        }
      }

      Text {
        text: root.entry.genericName ?? root.entry.comment ?? ""
        textFormat: Text.PlainText
        color: root.theme.textMuted
        elide: Text.ElideRight
        visible: text !== ""
        font.pixelSize: 11
        font.family: root.font
        Layout.fillWidth: true
      }
    }
  }

  MouseArea {
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    anchors.fill: parent
    onClicked: root.activated(root.entry)
    onPositionChanged: root.hovered(root.entryIndex)
  }
}

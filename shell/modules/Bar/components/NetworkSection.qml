import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking
import qs.config

Item {
  id: root

  required property Theme theme
  required property string font
  required property string title
  required property list<WifiNetwork> networks
  property bool collapsible: false
  property bool expanded: !collapsible
  property string emptyText: ""

  signal networkActivated(var network)

  implicitHeight: content.implicitHeight

  ColumnLayout {
    id: content
    spacing: 6
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
    }
    RowLayout {
      Layout.fillWidth: true

      Text {
        text: root.title
        color: root.theme.textSecondary
        font.family: root.font
        font.pixelSize: 11
        Layout.fillWidth: true
      }

      Button {
        visible: root.collapsible
        text: root.expanded ? qsTr("Hide") : qsTr("Show")
        Accessible.name: root.expanded
          ? qsTr("Hide %1").arg(root.title)
          : qsTr("Show %1").arg(root.title)
        onClicked: root.expanded = !root.expanded
      }
    }

    Loader {
      id: networkListLoader
      active: root.expanded
      sourceComponent: Component {
        ColumnLayout {
          width: networkListLoader.width
          spacing: 6

            Text {
            visible: root.networks.length === 0 && root.emptyText.length > 0
            text: root.emptyText
            color: root.theme.textMuted
            font.family: root.font
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
          }

          Repeater {
            model: root.networks

            delegate: NetworkRow {
              required property WifiNetwork modelData
              theme: root.theme
              font: root.font
              network: modelData
              Layout.fillWidth: true
              onActivated: root.networkActivated(modelData)
            }
          }
        }
      }
      Layout.fillWidth: true

    }
  }
}

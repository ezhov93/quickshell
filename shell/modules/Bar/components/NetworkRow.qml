import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.modules.Bar.services
import qs.config

Rectangle {
  id: root

  required property Theme theme
  required property string font
  required property WifiNetwork network
  signal activated()

  implicitHeight: 42
  radius: 6
  color: mouse.containsMouse ? root.theme.bgHover : root.theme.bgSurface
  activeFocusOnTab: true
  Accessible.role: Accessible.Button
  Accessible.name: qsTr("Network %1, %2").arg(network.name).arg(statusLabel)
  Accessible.onPressAction: root.activated()

  Keys.onPressed: event => {
    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
      root.activated();
      event.accepted = true;
    }
  }

  readonly property string signalIcon: {
    if (network.signalStrength >= 75) return "󰤨";
    if (network.signalStrength >= 50) return "󰤥";
    if (network.signalStrength >= 25) return "󰤢";
    return "󰤟";
  }
  RowLayout {
    spacing: 8

    anchors.fill: parent
    anchors.margins: 8
    Text {
      text: root.signalIcon
      color: root.theme.accentCyan
      horizontalAlignment: Text.AlignHCenter
      font.family: root.font
      font.pixelSize: 18
      Layout.preferredWidth: 22
      Layout.alignment: Qt.AlignVCenter
    }

    ColumnLayout {
      spacing: 2

      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      Text {
        text: root.network.name
        color: root.theme.textPrimary
        elide: Text.ElideRight
        font.family: root.font
        font.pixelSize: 13
        Layout.fillWidth: true
      }

      Text {
        text: root.statusLabel
        color: root.network.connected ? root.theme.accentGreen : root.theme.textMuted
        font.family: root.font
        font.pixelSize: 10
        Layout.fillWidth: true
      }
    }

    Text {
      text: root.network.stateChanging ? "…" : root.network.connected ? "󰄬" : ""
      color: root.theme.accentGreen
      horizontalAlignment: Text.AlignHCenter
      font.family: root.font
      font.pixelSize: 16
      Layout.preferredWidth: 32
      Layout.alignment: Qt.AlignVCenter
    }
  }

  MouseArea {
    id: mouse
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    anchors.fill: parent
    onClicked: root.activated()
  }
  readonly property string securityLabel: NetworkService.securityLabel(network)
  readonly property string statusLabel: network.connected
    ? qsTr("Connected · %1").arg(securityLabel)
    : securityLabel

}

import QtQuick
import Quickshell
import qs.modules.Bar.services

BarButton {
  id: root
  property bool popoverOpen: false

  width: content.width + 12
  Accessible.name: qsTr("Network: %1").arg(root.networkName)
  Accessible.description: qsTr("Open Wi-Fi network menu")
  onClicked: root.popoverOpen = !root.popoverOpen

  readonly property string networkIcon: {
    if (NetworkService.type === "ethernet") return "󰈀";
    if (NetworkService.type === "wifi") return "󰖩";
    return "󰖪";
  }

  readonly property string networkName: {
    if (NetworkService.type === "ethernet") return qsTr("Ethernet");
    if (NetworkService.type === "wifi") return qsTr("WiFi");
    return NetworkService.type;
  }

  Row {
    id: content
    spacing: 6

    anchors.centerIn: parent
    Text {
      text: root.networkIcon
      color: NetworkService.type === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 14
      font.family: root.font
    }
  }

  LazyLoader {
    id: popoverLoader
    active: root.popoverOpen
    component: NetworkPopover {
      anchorItem: root
      theme: root.theme
      font: root.font
      visible: root.popoverOpen
      onClosedByUser: root.popoverOpen = false
    }
  }
}

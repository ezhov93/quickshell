import QtQuick
import qs.modules.Bar.services

BarButton {
  id: root

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

  width: content.width + 12
  Accessible.name: qsTr("Network: %1").arg(root.networkName)
  Accessible.description: qsTr("Open network settings (nmtui)")

  Row {
    id: content
    anchors.centerIn: parent
    spacing: 6

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.networkIcon
      color: NetworkService.type === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
      font.pixelSize: 14
      font.family: root.font
    }
  }

  onClicked: NetworkService.openSettings()
}

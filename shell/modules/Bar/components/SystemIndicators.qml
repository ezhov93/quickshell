import QtQuick
import qs.modules.Bar.services

Row {
  id: indicatorsRoot
  required property var theme
  required property string font
  signal openNetworkSettings()
  readonly property string cpuLabel: Number.isFinite(ResourceService.cpuUsage) ? Math.round(ResourceService.cpuUsage * 100) + "%" : "N/A"
  readonly property string temperatureLabel: Number.isFinite(ResourceService.temperature) ? Math.round(ResourceService.temperature) + "°C" : "N/A"
  readonly property string batteryLabel: Number.isFinite(BatteryService.charge) ? Math.round(BatteryService.charge * 100) + "%" : "N/A"
  readonly property string batteryIcon: {
    if (BatteryService.charging) return "";
    if (!Number.isFinite(BatteryService.charge)) return "󰂎";
    const icons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
    return icons[Math.min(9, Math.max(0, Math.floor(BatteryService.charge * 10)))];
  }


  readonly property color batteryColor: {
    if (BatteryService.charging) return indicatorsRoot.theme.accentGreen;
    if (Math.round(BatteryService.charge * 100) > 20) return indicatorsRoot.theme.batteryGood;
    if (Math.round(BatteryService.charge * 100) > 10) return indicatorsRoot.theme.batteryWarning;
    return indicatorsRoot.theme.batteryCritical;
  }

  spacing: 4

  // CPU
  BarButton {
    interactive: false
    theme: indicatorsRoot.theme
    font: indicatorsRoot.font
    width: cpuContent.width + 12
    Accessible.role: Accessible.StaticText
    Accessible.name: "CPU: " + indicatorsRoot.cpuLabel

    Row {
      id: cpuContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "󰻠"
        color: indicatorsRoot.theme.accentOrange
        font.pixelSize: 14
        font.family: indicatorsRoot.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: indicatorsRoot.cpuLabel
        color: indicatorsRoot.theme.textPrimary
        font.pixelSize: 11
        font.family: indicatorsRoot.font
      }
    }
  }

  // Temperature
  BarButton {
    interactive: false
    theme: indicatorsRoot.theme
    font: indicatorsRoot.font
    width: tempContent.width + 12
    Accessible.role: Accessible.StaticText
    Accessible.name: "Temperature: " + indicatorsRoot.temperatureLabel

    Row {
      id: tempContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "󰔏"
        color: indicatorsRoot.theme.accentRed
        font.pixelSize: 14
        font.family: indicatorsRoot.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: indicatorsRoot.temperatureLabel
        color: indicatorsRoot.theme.textPrimary
        font.pixelSize: 11
        font.family: indicatorsRoot.font
      }
    }
  }

  // Network
  BarButton {
    theme: indicatorsRoot.theme
    font: indicatorsRoot.font
    width: netContent.width + 12
    Accessible.role: Accessible.Button
    Accessible.name: {
      if (NetworkService.type === "ethernet") return "Network: Ethernet"
      if (NetworkService.type === "wifi") return "Network: WiFi " + NetworkService.name
      return "Network: " + NetworkService.name
    }
    Accessible.description: "Open network settings (nmtui)"
    Accessible.onPressAction: indicatorsRoot.openNetworkSettings()

    Row {
      id: netContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
          if (NetworkService.type === "ethernet") return "󰈀"
          if (NetworkService.type === "wifi") return "󰖩"
          return "󰖪"
        }
        color: NetworkService.type === "disconnected" ? indicatorsRoot.theme.textMuted : indicatorsRoot.theme.accentGreen
        font.pixelSize: 14
        font.family: indicatorsRoot.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: NetworkService.name
        color: indicatorsRoot.theme.textPrimary
        font.pixelSize: 11
        font.family: indicatorsRoot.font
      }
    }

    onClicked: indicatorsRoot.openNetworkSettings()
  }

  // Battery
  BarButton {
    visible: BatteryService.available
    interactive: false
    theme: indicatorsRoot.theme
    font: indicatorsRoot.font
    width: battContent.width + 12
    Accessible.role: Accessible.StaticText
    Accessible.name: "Battery: " + indicatorsRoot.batteryLabel

    Row {
      id: battContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: indicatorsRoot.batteryIcon
        color: indicatorsRoot.batteryColor
        font.pixelSize: 14
        font.family: indicatorsRoot.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: indicatorsRoot.batteryLabel
        color: indicatorsRoot.theme.textPrimary
        font.pixelSize: 11
        font.family: indicatorsRoot.font
      }
    }
  }
}

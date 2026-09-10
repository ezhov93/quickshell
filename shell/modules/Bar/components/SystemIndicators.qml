import QtQuick
import qs.modules.Bar.services

Row {
  id: root
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
    if (BatteryService.charging) return root.theme.accentGreen;
    if (Math.round(BatteryService.charge * 100) > 20) return root.theme.batteryGood;
    if (Math.round(BatteryService.charge * 100) > 10) return root.theme.batteryWarning;
    return root.theme.batteryCritical;
  }

  spacing: 4

  // CPU
  Rectangle {
    height: 24
    width: cpuContent.width + 12
    radius: 12
    color: root.theme.bgSurface
    Accessible.role: Accessible.StaticText
    Accessible.name: "CPU: " + root.cpuLabel

    Row {
      id: cpuContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "󰻠"
        color: root.theme.accentOrange
        font.pixelSize: 14
        font.family: root.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.cpuLabel
        color: root.theme.textPrimary
        font.pixelSize: 11
        font.family: root.font
      }
    }
  }

  // Temperature
  Rectangle {
    height: 24
    width: tempContent.width + 12
    radius: 12
    color: root.theme.bgSurface
    Accessible.role: Accessible.StaticText
    Accessible.name: "Temperature: " + root.temperatureLabel

    Row {
      id: tempContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "󰔏"
        color: root.theme.accentRed
        font.pixelSize: 14
        font.family: root.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.temperatureLabel
        color: root.theme.textPrimary
        font.pixelSize: 11
        font.family: root.font
      }
    }
  }

  // Network
  Rectangle {
    height: 24
    width: netContent.width + 12
    radius: 12
    color: networkMouse.containsMouse ? root.theme.bgHover : root.theme.bgSurface
    Accessible.role: Accessible.Button
    Accessible.name: {
      if (NetworkService.type === "ethernet") return "Network: Ethernet"
      if (NetworkService.type === "wifi") return "Network: WiFi " + NetworkService.name
      return "Network: " + NetworkService.name
    }
    Accessible.description: "Open network settings (nmtui)"
    Accessible.onPressAction: root.openNetworkSettings()

    MouseArea {
      id: networkMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.openNetworkSettings()
    }

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
        color: NetworkService.type === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
        font.pixelSize: 14
        font.family: root.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: NetworkService.name
        color: root.theme.textPrimary
        font.pixelSize: 11
        font.family: root.font
      }
    }
  }

  // Battery
  Rectangle {
    visible: BatteryService.available
    height: 24
    width: battContent.width + 12
    radius: 12
    color: root.theme.bgSurface
    Accessible.role: Accessible.StaticText
    Accessible.name: "Battery: " + root.batteryLabel

    Row {
      id: battContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.batteryIcon
        color: root.batteryColor
        font.pixelSize: 14
        font.family: root.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.batteryLabel
        color: root.theme.textPrimary
        font.pixelSize: 11
        font.family: root.font
      }
    }
  }
}

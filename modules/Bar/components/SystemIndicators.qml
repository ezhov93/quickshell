import "../services"
import QtQuick

Row {
  id: root
  required property var theme
  required property string font
  signal openNetworkSettings()


  readonly property color batteryColor: {
    if (SystemInfo.batteryCharging) return root.theme.accentGreen;
    if (SystemInfo.batteryLevelRaw > 20) return root.theme.batteryGood;
    if (SystemInfo.batteryLevelRaw > 10) return root.theme.batteryWarning;
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
    Accessible.name: "CPU: " + SystemInfo.cpuUsage

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
        text: SystemInfo.cpuUsage
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
    Accessible.name: "Temperature: " + SystemInfo.temperature

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
        text: SystemInfo.temperature
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
      if (SystemInfo.networkType === "ethernet") return "Network: Ethernet"
      if (SystemInfo.networkType === "wifi") return "Network: WiFi " + SystemInfo.networkInfo
      return "Network: " + SystemInfo.networkInfo
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
          if (SystemInfo.networkType === "ethernet") return "󰈀"
          if (SystemInfo.networkType === "wifi") return "󰖩"
          return "󰖪"
        }
        color: SystemInfo.networkType === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
        font.pixelSize: 14
        font.family: root.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: SystemInfo.networkInfo
        color: root.theme.textPrimary
        font.pixelSize: 11
        font.family: root.font
      }
    }
  }

  // Battery
  Rectangle {
    height: 24
    width: battContent.width + 12
    radius: 12
    color: root.theme.bgSurface
    Accessible.role: Accessible.StaticText
    Accessible.name: "Battery: " + SystemInfo.batteryLevel

    Row {
      id: battContent
      anchors.centerIn: parent
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: SystemInfo.batteryIcon
        color: root.batteryColor
        font.pixelSize: 14
        font.family: root.font
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: SystemInfo.batteryLevel
        color: root.theme.textPrimary
        font.pixelSize: 11
        font.family: root.font
      }
    }
  }
}

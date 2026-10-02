import QtQuick
import qs.modules.Bar.services

BarPill {
  id: root

  readonly property string valueText: Number.isFinite(BatteryService.charge)
    ? Math.round(BatteryService.charge * 100) + "%"
    : "N/A"

  readonly property string batteryIcon: {
    if (BatteryService.charging) return "";
    if (!Number.isFinite(BatteryService.charge)) return "󰂎";
    const icons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
    return icons[Math.min(9, Math.max(0, Math.floor(BatteryService.charge * 10)))];
  }

  readonly property color batteryColor: {
    if (!Number.isFinite(BatteryService.charge)) return root.theme.textMuted;
    if (BatteryService.charging) return root.theme.accentGreen;
    if (Math.round(BatteryService.charge * 100) > 20) return root.theme.batteryGood;
    if (Math.round(BatteryService.charge * 100) > 10) return root.theme.batteryWarning;
    return root.theme.batteryCritical;
  }

  visible: BatteryService.available
  width: content.width + 12
  Accessible.role: Accessible.StaticText
  Accessible.name: qsTr("Battery: %1").arg(root.valueText)

  Row {
    id: content
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
      text: root.valueText
      color: root.theme.textPrimary
      font.pixelSize: 11
      font.family: root.font
    }
  }
}

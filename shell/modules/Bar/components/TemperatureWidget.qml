import QtQuick
import qs.modules.Bar.services

BarPill {
  id: root

  readonly property string valueText: Number.isFinite(ResourceService.temperature)
    ? Math.round(ResourceService.temperature) + "°C"
    : "N/A"

  width: content.width + 12
  Accessible.role: Accessible.StaticText
  Accessible.name: qsTr("Temperature: %1").arg(root.valueText)

  Row {
    id: content
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
      text: root.valueText
      color: root.theme.textPrimary
      font.pixelSize: 11
      font.family: root.font
    }
  }
}

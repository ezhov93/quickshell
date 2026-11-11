import QtQuick
import qs.modules.Bar.services

BarPill {
  id: root

  width: content.width + 12
  Accessible.role: Accessible.StaticText
  Accessible.name: qsTr("Temperature: %1").arg(root.valueText)

  Row {
    id: content
    spacing: 6

    anchors.centerIn: parent
    Text {
      text: "󰔏"
      color: root.theme.accentRed
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 14
      font.family: root.font
    }

    Text {
      text: root.valueText
      color: root.theme.textPrimary
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 11
      font.family: root.font
    }
  }
  readonly property string valueText: Number.isFinite(ResourceService.temperature)
    ? Math.round(ResourceService.temperature) + "°C"
    : "N/A"

}

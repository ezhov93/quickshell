import QtQuick
import qs.modules.Bar.services

BarPill {
  id: root

  visible: KeyboardLayoutService.label !== ""
  width: label.implicitWidth + 16
  Accessible.role: Accessible.StaticText
  Accessible.name: qsTr("Keyboard layout: %1").arg(KeyboardLayoutService.layoutName)

  Text {
    id: label
    anchors.centerIn: parent
    text: KeyboardLayoutService.label
    color: root.theme.accentPrimary
    font {
      pixelSize: 11
      family: root.font
      bold: true
    }
  }
}

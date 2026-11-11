import QtQuick
import qs.config

Row {
  id: root

  required property Theme theme
  required property string font
  required property string shortcut
  required property string description

  spacing: 4

  Rectangle {
    width: shortcutText.implicitWidth + 8
    height: 18
    radius: 4
    color: root.theme.bgSurface

    Text {
      id: shortcutText
      text: root.shortcut
      textFormat: Text.PlainText
      color: root.theme.textMuted
      anchors.centerIn: parent
      font.pixelSize: 10
      font.family: root.font
    }
  }

  Text {
    text: root.description
    textFormat: Text.PlainText
    color: root.theme.textMuted
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: 10
    font.family: root.font
  }
}

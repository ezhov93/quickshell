import QtQuick

Row {
  id: root

  required property var theme
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
      anchors.centerIn: parent
      text: root.shortcut
      textFormat: Text.PlainText
      color: root.theme.textMuted
      font.pixelSize: 10
      font.family: root.font
    }
  }

  Text {
    anchors.verticalCenter: parent.verticalCenter
    text: root.description
    textFormat: Text.PlainText
    color: root.theme.textMuted
    font.pixelSize: 10
    font.family: root.font
  }
}

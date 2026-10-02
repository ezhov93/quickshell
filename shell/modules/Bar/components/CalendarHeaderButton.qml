import QtQuick
import QtQuick.Controls.Basic

Button {
  id: root

  required property var theme
  required property string fontFamily

  implicitWidth: Math.max(30, label.implicitWidth + 14)
  implicitHeight: 30
  focusPolicy: Qt.StrongFocus

  contentItem: Text {
    id: label
    text: root.text
    color: root.enabled ? root.theme.textPrimary : root.theme.textMuted
    font.family: root.fontFamily
    font.pixelSize: 12
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  background: Rectangle {
    color: root.down ? root.theme.bgSelected : root.hovered ? root.theme.bgHover : root.theme.bgSurface
    border.color: root.activeFocus ? root.theme.accentPrimary : root.theme.bgBorder
    border.width: 1
    radius: 6
  }
}

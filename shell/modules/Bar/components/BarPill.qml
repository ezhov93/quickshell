import QtQuick

Rectangle {
  id: root

  required property var theme
  required property string font
  property color baseColor: root.theme.bgSurface
  property color hoverColor: root.theme.bgHover
  property bool hovered: false
  property int horizontalPadding: 6
  property int verticalPadding: 0

  default property alias contentData: content.data

  implicitWidth: content.childrenRect.width + horizontalPadding * 2
  implicitHeight: 24
  radius: height / 2
  color: root.hovered ? root.hoverColor : root.baseColor

  Item {
    id: content
    anchors {
      fill: parent
      leftMargin: root.horizontalPadding
      rightMargin: root.horizontalPadding
      topMargin: root.verticalPadding
      bottomMargin: root.verticalPadding
    }
  }
}

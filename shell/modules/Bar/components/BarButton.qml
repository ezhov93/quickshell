import QtQuick

Rectangle {
  id: root

  property var theme
  property string font: ""

  property bool interactive: true
  property color baseColor: root.theme ? root.theme.bgSurface : "transparent"
  property color hoverColor: root.theme ? root.theme.bgHover : "transparent"
  property int horizontalPadding: 6
  property int verticalPadding: 0

  default property alias contentData: content.data

  signal clicked()
  signal wheelUp()
  signal wheelDown()

  implicitWidth: content.childrenRect.width + horizontalPadding * 2
  implicitHeight: 24
  radius: height / 2
  color: mouseArea.containsMouse && root.interactive ? root.hoverColor : root.baseColor

  Item {
    id: content
    anchors.fill: parent
    anchors.leftMargin: root.horizontalPadding
    anchors.rightMargin: root.horizontalPadding
    anchors.topMargin: root.verticalPadding
    anchors.bottomMargin: root.verticalPadding
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.interactive
    hoverEnabled: root.interactive
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton
    onClicked: root.clicked()
    onWheel: (wheel) => {
      if (wheel.angleDelta.y > 0) root.wheelUp();
      else if (wheel.angleDelta.y < 0) root.wheelDown();
    }
  }
}

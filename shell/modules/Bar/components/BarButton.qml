import QtQuick

BarPill {
  id: root

  signal clicked()
  signal wheelUp()
  signal wheelDown()

  hovered: inputArea.containsMouse
  activeFocusOnTab: true
  Accessible.role: Accessible.Button
  Accessible.onPressAction: root.clicked()

  Keys.onPressed: event => {
    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
      root.clicked();
      event.accepted = true;
    }
  }

  readonly property MouseArea inputArea: MouseArea {
    parent: root
    anchors.fill: parent
    z: 1
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton
    onClicked: root.clicked()
    onWheel: (wheel) => {
      if (wheel.angleDelta.y > 0) root.wheelUp();
      else if (wheel.angleDelta.y < 0) root.wheelDown();
    }
  }
}

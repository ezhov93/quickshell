import QtQuick

Rectangle {
  id: root
  required property var theme
  required property string font
  required property string previewPath
  signal closeRequested()
  signal applyRequested(string path)

  anchors.fill: parent
  color: Qt.rgba(0, 0, 0, 0.85)
  visible: root.previewPath !== ""

  MouseArea {
    anchors.fill: parent
    onClicked: root.closeRequested()
  }

  Image {
    anchors.centerIn: parent
    width: parent.width * 0.8
    height: parent.height * 0.8
    source: root.previewPath !== "" ? "file://" + root.previewPath : ""
    fillMode: Image.PreserveAspectFit
    asynchronous: true
  }

  // Apply button
  Rectangle {
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 40
    width: applyRow.width + 32
    height: 40
    radius: 20
    color: root.theme.accentPrimary
    Accessible.role: Accessible.Button
    Accessible.name: "Apply wallpaper"

    Row {
      id: applyRow
      anchors.centerIn: parent
      spacing: 8

      Text {
        text: ""
        color: root.theme.bgBase
        font.pixelSize: 14
        font.family: root.font
        anchors.verticalCenter: parent.verticalCenter
      }
      Text {
        text: "Apply Wallpaper"
        color: root.theme.bgBase
        font.pixelSize: 13
        font.family: root.font
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        root.applyRequested(root.previewPath);
        root.closeRequested();
      }
    }
  }
}

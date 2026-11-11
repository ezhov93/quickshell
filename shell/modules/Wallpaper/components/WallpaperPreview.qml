import QtQuick
import qs.config

Rectangle {
  id: root
  required property Theme theme
  required property string font
  required property string previewPath
  signal closeRequested()
  signal applyRequested(string path)

  color: Qt.rgba(0, 0, 0, 0.85)
  visible: root.previewPath !== ""

  anchors.fill: parent
  MouseArea {
    anchors.fill: parent
    onClicked: root.closeRequested()
  }

  Image {
    width: parent.width * 0.8
    height: parent.height * 0.8
    source: root.previewPath !== "" ? "file://" + root.previewPath.split("/").map(encodeURIComponent).join("/") : ""
    cache: false
    fillMode: Image.PreserveAspectFit
    asynchronous: true
    anchors.centerIn: parent
    sourceSize.width: Math.ceil(width)
    sourceSize.height: Math.ceil(height)
  }

  Rectangle {
    width: applyRow.width + 32
    height: 40
    radius: 20
    color: root.theme.accentPrimary
    Accessible.role: Accessible.Button
    Accessible.name: "Apply wallpaper"
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 40
    }
    Row {
      id: applyRow
      spacing: 8

      anchors.centerIn: parent
      Text {
        text: ""
        color: root.theme.bgBase
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
        font.family: root.font
      }
      Text {
        text: "Apply Wallpaper"
        color: root.theme.bgBase
        anchors.verticalCenter: parent.verticalCenter
        font {
          pixelSize: 13
          family: root.font
          bold: true
        }
      }
    }

    MouseArea {
      cursorShape: Qt.PointingHandCursor
      anchors.fill: parent
      onClicked: {
        root.applyRequested(root.previewPath);
        root.closeRequested();
      }
    }
  }
  // Apply button
}

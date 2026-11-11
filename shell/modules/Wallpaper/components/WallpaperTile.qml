import QtQuick
import qs.config

Item {
  id: root
  required property Theme theme
  required property string font
  required property string currentWallpaper
  required property string modelData
  required property int index

  signal previewRequested(string path)
  signal applyRequested(string path)

  Accessible.role: Accessible.Button
  Accessible.name: modelData.split("/").pop() + (root.currentWallpaper === modelData ? ", current wallpaper" : "")


  Rectangle {
    radius: 8
    color: root.theme.bgSurface
    clip: true

    anchors.fill: parent
    anchors.margins: 4
    border.color: root.currentWallpaper === modelData ? root.theme.accentPrimary : (imgHover.containsMouse ? root.theme.bgBorder : "transparent")
    border.width: root.currentWallpaper === modelData ? 2 : 1
    Image {
      source: "file://" + modelData.split("/").map(encodeURIComponent).join("/")
      fillMode: Image.PreserveAspectCrop
      asynchronous: true

      anchors.fill: parent
      anchors.margins: 2
      sourceSize.width: 200
      sourceSize.height: 120
      Rectangle {
        color: root.theme.bgSurface
        visible: parent.status !== Image.Ready

        anchors.fill: parent
        Text {
          text: "󰋩"
          color: root.theme.textMuted
          anchors.centerIn: parent
          font.pixelSize: 24
          font.family: root.font
        }
      }
    }

    Rectangle {
      height: 22
      color: Qt.rgba(0, 0, 0, 0.6)
      anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
      }
      Text {
        text: modelData.split("/").pop()
        color: "#ffffff"
        elide: Text.ElideMiddle
        width: parent.width - 8
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
        font.pixelSize: 9
        font.family: root.font
      }
    }

    Rectangle {
      width: 20
      height: 20
      radius: 10
      color: root.theme.accentGreen
      visible: root.currentWallpaper === modelData
      anchors {
        top: parent.top
        right: parent.right
        margins: 6
      }
      Text {
        text: ""
        color: root.theme.bgBase
        anchors.centerIn: parent
        font.pixelSize: 12
        font.family: root.font
      }
    }

    MouseArea {
      id: imgHover
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      anchors.fill: parent
      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
          root.previewRequested(modelData);
        } else {
          root.applyRequested(modelData);
        }
      }
    }
    // Filename label
    // Active indicator
  }
}

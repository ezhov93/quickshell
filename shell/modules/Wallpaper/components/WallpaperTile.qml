import QtQuick

Item {
  id: root
  required property var theme
  required property string font
  required property string currentWallpaper
  signal previewRequested(string path)
  signal applyRequested(string path)

  required property string modelData
  required property int index

  Accessible.role: Accessible.Button
  Accessible.name: modelData.split("/").pop() + (root.currentWallpaper === modelData ? ", current wallpaper" : "")


  Rectangle {
    anchors.fill: parent
    anchors.margins: 4
    radius: 8
    color: root.theme.bgSurface
    border.color: root.currentWallpaper === modelData ? root.theme.accentPrimary : (imgHover.containsMouse ? root.theme.bgBorder : "transparent")
    border.width: root.currentWallpaper === modelData ? 2 : 1
    clip: true

    Image {
      anchors.fill: parent
      anchors.margins: 2
      source: "file://" + modelData.split("/").map(encodeURIComponent).join("/")
      fillMode: Image.PreserveAspectCrop
      sourceSize.width: 200
      sourceSize.height: 120
      asynchronous: true

      Rectangle {
        anchors.fill: parent
        color: root.theme.bgSurface
        visible: parent.status !== Image.Ready

        Text {
          anchors.centerIn: parent
          text: "󰋩"
          color: root.theme.textMuted
          font.pixelSize: 24
          font.family: root.font
        }
      }
    }

    // Filename label
    Rectangle {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: 22
      color: Qt.rgba(0, 0, 0, 0.6)

      Text {
        anchors.centerIn: parent
        text: modelData.split("/").pop()
        color: "#ffffff"
        font.pixelSize: 9
        font.family: root.font
        elide: Text.ElideMiddle
        width: parent.width - 8
        horizontalAlignment: Text.AlignHCenter
      }
    }

    // Active indicator
    Rectangle {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.margins: 6
      width: 20
      height: 20
      radius: 10
      color: root.theme.accentGreen
      visible: root.currentWallpaper === modelData

      Text {
        anchors.centerIn: parent
        text: ""
        color: root.theme.bgBase
        font.pixelSize: 12
        font.family: root.font
      }
    }

    MouseArea {
      id: imgHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
          root.previewRequested(modelData);
        } else {
          root.applyRequested(modelData);
        }
      }
    }
  }
}

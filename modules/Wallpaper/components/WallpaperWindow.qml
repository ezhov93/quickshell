import qs.config
import qs.modules.Wallpaper.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: root
  required property var theme
  property string font: Config.fontFamily
  signal closeRequested()
  onVisibleChanged: if (!visible) previewPath = ""
  Component.onCompleted: searchInput.forceActiveFocus()

  property string searchText: ""
  property string previewPath: ""

  property var filteredWallpapers: {
    const q = searchText.toLowerCase();
    if (q === "") return WallpaperService.wallpapers;
    return WallpaperService.wallpapers.filter(p => {
      const name = p.split("/").pop().toLowerCase();
      return name.includes(q);
    });
  }

  visible: true
  focusable: true
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "quickshell-wallpaper"

  exclusionMode: ExclusionMode.Ignore

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  // Dark overlay backdrop
  MouseArea {
    anchors.fill: parent
    onClicked: root.closeRequested()

    Rectangle {
      anchors.fill: parent
      color: root.theme.bgOverlay
    }
  }

  // Main wallpaper picker box
  Rectangle {
    anchors.centerIn: parent
    width: 720
    height: 560
    radius: 16
    color: root.theme.bgBase
    border.color: root.theme.bgBorder
    border.width: 1

    MouseArea {
      anchors.fill: parent
      onClicked: event => event.accepted = true
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 12

      // Header
      RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Text {
          text: "󰸉  Wallpaper"
          color: root.theme.accentPrimary
          font.pixelSize: 14
          font.family: root.font
          font.bold: true
        }

        Item { Layout.fillWidth: true }

        Text {
          text: root.filteredWallpapers.length + " images"
          color: root.theme.textMuted
          font.pixelSize: 11
          font.family: root.font
        }

        // Refresh button
        Rectangle {
          width: 28
          height: 28
          radius: 14
          color: refreshHover.containsMouse ? root.theme.bgHover : "transparent"
          Accessible.role: Accessible.Button
          Accessible.name: "Refresh wallpaper list"

          Text {
            anchors.centerIn: parent
            text: "󰑐"
            color: root.theme.textMuted
            font.pixelSize: 14
            font.family: root.font
          }

          MouseArea {
            id: refreshHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: WallpaperService.rescan()
          }
        }
      }

      Text {
        Layout.fillWidth: true
        text: WallpaperService.applyError.trim()
        visible: text !== ""
        color: root.theme.accentRed
        wrapMode: Text.Wrap
        font.family: root.font
        font.pixelSize: 11
      }

      // Search
      Rectangle {
        Layout.fillWidth: true
        height: 36
        radius: 8
        color: root.theme.bgSurface
        border.color: searchInput.activeFocus ? root.theme.accentPrimary : root.theme.bgBorder
        border.width: 1

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8

          Text {
            text: ""
            color: root.theme.textMuted
            font.pixelSize: 13
            font.family: root.font
            Layout.alignment: Qt.AlignVCenter
          }

          TextInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            color: root.theme.textPrimary
            font.pixelSize: 13
            font.family: root.font
            clip: true
            selectByMouse: true
            Accessible.role: Accessible.EditableText
            Accessible.name: "Search wallpapers"
            onTextChanged: root.searchText = text

            Keys.onEscapePressed: {
              if (root.previewPath !== "") {
                root.previewPath = "";
              } else {
                root.closeRequested();
              }
            }
          }

          Text {
            text: "Search wallpapers..."
            color: root.theme.textMuted
            font.pixelSize: 13
            font.family: root.font
            visible: searchInput.text === "" && !searchInput.activeFocus
          }
        }
      }

      // Wallpaper grid
      GridView {
        id: wallpaperGrid
        Layout.fillWidth: true
        Layout.fillHeight: true
        cellWidth: Math.floor(width / 4)
        cellHeight: cellWidth * 0.6 + 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: root.filteredWallpapers

        delegate: WallpaperTile {
          theme: root.theme
          font: root.font
          width: wallpaperGrid.cellWidth
          height: wallpaperGrid.cellHeight
          currentWallpaper: WallpaperService.currentWallpaper
          onPreviewRequested: path => root.previewPath = path
          onApplyRequested: path => WallpaperService.setWallpaper(path)
        }

        // Empty state
        Text {
          anchors.centerIn: parent
          text: "󰋩  No wallpapers found\nAdd images to ~/Pictures/Wallpapers/"
          color: root.theme.textMuted
          font.pixelSize: 13
          font.family: root.font
          horizontalAlignment: Text.AlignHCenter
          visible: wallpaperGrid.count === 0
        }
      }

      // Footer
      RowLayout {
        Layout.fillWidth: true
        spacing: 16

        Row {
          spacing: 4
          Rectangle {
            width: hintClick.width + 8; height: 18; radius: 4; color: root.theme.bgSurface
            Text { id: hintClick; anchors.centerIn: parent; text: "click"; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font }
          }
          Text { text: "apply"; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font; anchors.verticalCenter: parent.verticalCenter }
        }

        Row {
          spacing: 4
          Rectangle {
            width: hintRight.width + 8; height: 18; radius: 4; color: root.theme.bgSurface
            Text { id: hintRight; anchors.centerIn: parent; text: "right-click"; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font }
          }
          Text { text: "preview"; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font; anchors.verticalCenter: parent.verticalCenter }
        }

        Row {
          spacing: 4
          Text { text: "Backend: " + WallpaperService.backend; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font; anchors.verticalCenter: parent.verticalCenter }
        }

        Item { Layout.fillWidth: true }
      }
    }
  }

  // Preview overlay
  WallpaperPreview {
    theme: root.theme
    font: root.font
    previewPath: root.previewPath
    onCloseRequested: root.previewPath = ""
    onApplyRequested: path => WallpaperService.setWallpaper(path)
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.modules.Wallpaper.services

PanelWindow {
  id: root
  required property Theme theme
  property string font: Config.fontFamily
  property string searchText: ""
  property string previewPath: ""

  property list<var> filteredWallpapers: {
    const q = searchText.toLowerCase();
    if (q === "") return WallpaperService.wallpapers;
    return WallpaperService.wallpapers.filter(p => {
      const name = p.split("/").pop().toLowerCase();
      return name.includes(q);
    });
  }

  signal closeRequested()
  visible: true
  focusable: true
  color: "transparent"

  exclusionMode: ExclusionMode.Ignore

  onVisibleChanged: if (!visible) previewPath = ""
  Component.onCompleted: searchInput.forceActiveFocus()

  WlrLayershell {
    layer: WlrLayer.Overlay
    keyboardFocus: WlrKeyboardFocus.Exclusive
    namespace: "quickshell-wallpaper"
  }

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.closeRequested()

    Rectangle {
      color: root.theme.bgOverlay
      anchors.fill: parent
    }
  }

  Rectangle {
    width: 720
    height: 560
    radius: 16
    color: root.theme.bgBase
    anchors.centerIn: parent
    border.color: root.theme.bgBorder
    border.width: 1

    MouseArea {
      anchors.fill: parent
      onClicked: event => event.accepted = true
    }

    ColumnLayout {
      spacing: 12

      anchors.fill: parent
      anchors.margins: 16
      RowLayout {
        spacing: 12

        Layout.fillWidth: true
        Text {
          text: "󰸉  Wallpaper"
          color: root.theme.accentPrimary
          font {
            pixelSize: 14
            family: root.font
            bold: true
          }
        }

        Item { Layout.fillWidth: true }

        Text {
          text: root.filteredWallpapers.length + " images"
          color: root.theme.textMuted
          font.pixelSize: 11
          font.family: root.font
        }

        Rectangle {
          radius: 14
          color: refreshHover.containsMouse ? root.theme.bgHover : "transparent"
          Layout.preferredWidth: 28
          Layout.preferredHeight: 28
          Accessible.role: Accessible.Button
          Accessible.name: "Refresh wallpaper list"

          Text {
            text: "󰑐"
            color: root.theme.textMuted
            anchors.centerIn: parent
            font.pixelSize: 14
            font.family: root.font
          }

          MouseArea {
            id: refreshHover
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: WallpaperService.rescan()
          }
        }
        // Refresh button
      }

      Text {
        text: WallpaperService.applyError.trim()
        visible: text !== ""
        color: root.theme.accentRed
        wrapMode: Text.Wrap
        Layout.fillWidth: true
        font.family: root.font
        font.pixelSize: 11
      }

      Rectangle {
        radius: 8
        color: root.theme.bgSurface
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        border.color: searchInput.activeFocus ? root.theme.accentPrimary : root.theme.bgBorder
        border.width: 1

        RowLayout {
          spacing: 8

          anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
          }
          Text {
            text: ""
            color: root.theme.textMuted
            Layout.alignment: Qt.AlignVCenter
            font {
              pixelSize: 13
              family: root.font
            }
          }

          TextInput {
            id: searchInput
            color: root.theme.textPrimary
            clip: true
            selectByMouse: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 13
            font.family: root.font
            Accessible.role: Accessible.EditableText
            Accessible.name: "Search wallpapers"
            Keys.onEscapePressed: {
              if (root.previewPath !== "") {
                root.previewPath = "";
              } else {
                root.closeRequested();
              }
            }
            onTextChanged: root.searchText = text

          }

          Text {
            text: "Search wallpapers..."
            color: root.theme.textMuted
            visible: searchInput.text === "" && !searchInput.activeFocus
            font.pixelSize: 13
            font.family: root.font
          }
        }
      }

      GridView {
        id: wallpaperGrid
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

        Layout.fillWidth: true
        Layout.fillHeight: true
        Text {
          text: "󰋩  No wallpapers found\nAdd images to ~/Pictures/Wallpapers/"
          color: root.theme.textMuted
          horizontalAlignment: Text.AlignHCenter
          visible: wallpaperGrid.count === 0
          anchors.centerIn: parent
          font.pixelSize: 13
          font.family: root.font
        }
        // Empty state
      }

      RowLayout {
        spacing: 16

        Layout.fillWidth: true
        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "click"
          description: "apply"
        }

        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "right-click"
          description: "preview"
        }

        Row {
          spacing: 4
          Text { text: "Backend: " + WallpaperService.backend; color: root.theme.textMuted; font.pixelSize: 10; font.family: root.font; anchors.verticalCenter: parent.verticalCenter }
        }

        Item { Layout.fillWidth: true }
      }
      // Header
      // Search
      // Wallpaper grid
      // Footer
    }
  }

  WallpaperPreview {
    theme: root.theme
    font: root.font
    previewPath: root.previewPath
    onCloseRequested: root.previewPath = ""
    onApplyRequested: path => WallpaperService.setWallpaper(path)
  }
  // Dark overlay backdrop
  // Main wallpaper picker box
  // Preview overlay
}

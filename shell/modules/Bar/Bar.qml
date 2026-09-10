import qs.config
import qs.modules.Bar.components
import qs.modules.Bar.services
import Quickshell
import Quickshell.Io
import QtQuick
Scope {
  id: root
  property var theme: Theme
  property string font: Config.fontFamily
  property bool barVisible: true

  Binding { target: ResourceService; property: "active"; value: root.barVisible }
  Binding { target: NetworkService; property: "active"; value: root.barVisible }

  KeyboardLayout { id: keyboardLayout }

  IpcHandler {
    target: "bar"
    function toggle(): void { root.barVisible = !root.barVisible; }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: root.barVisible

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 32
      color: root.theme.bgBase

      Item {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // Left section: Workspaces
        Row {
          id: leftSection
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          // Workspaces
          WorkspaceList {
            theme: root.theme
            font: root.font
          }

        }

        // Active application beside workspaces; leave the remaining middle space empty.
        Item {
          anchors.left: leftSection.right
          anchors.right: rightSection.left
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          height: parent.height

          Text {
            Accessible.role: Accessible.StaticText
            Accessible.name: "Active window: " + text
            text: WorkspaceService.activeWindowTitle
            color: root.theme.textPrimary
            font.pixelSize: 13
            font.family: root.font
            elide: Text.ElideRight
            width: Math.max(0, Math.min(implicitWidth, parent.width))
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        // Right section: Tray, media, controls, system status, input language, clock
        Row {
          id: rightSection
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          // System Tray
          // There's an issue that some tray not display correctly.
          // https://github.com/quickshell-mirror/quickshell/issues/26
          // https://github.com/quickshell-mirror/quickshell/pull/777
          TrayWidget {
            theme: root.theme
            font: root.font
          }

          // Now Playing
          MediaWidget {
            theme: root.theme
            font: root.font
          }

          // Volume
          VolumeWidget {
            theme: root.theme
            font: root.font
          }

          // Brightness
          BrightnessWidget {
            theme: root.theme
            font: root.font
          }

          // System Info
          SystemIndicators {
            theme: root.theme
            font: root.font
            onOpenNetworkSettings: NetworkService.openSettings()
          }

          // Keyboard layout of Hyprland's main keyboard
          Rectangle {
            height: 24
            width: layoutText.implicitWidth + 16
            radius: 12
            color: root.theme.bgSurface
            visible: keyboardLayout.label !== ""

            Accessible.role: Accessible.StaticText
            Accessible.name: "Keyboard layout: " + keyboardLayout.layoutName

            Text {
              id: layoutText
              anchors.centerIn: parent
              text: keyboardLayout.label
              color: root.theme.accentPrimary
              font.pixelSize: 11
              font.family: root.font
              font.bold: true
            }
          }

          // Time
          Rectangle {
            height: 24
            width: timeDate.width + 16
            radius: 12
            color: root.theme.bgSurface

            Row {
              id: timeDate
              anchors.centerIn: parent
              spacing: 8

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: root.theme.accentPrimary
                font.pixelSize: 14
                font.family: root.font
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Time.dateString
                color: root.theme.textPrimary
                font.pixelSize: 12
                font.family: root.font
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Time.timeString
                color: root.theme.textSecondary
                font.pixelSize: 12
                font.family: root.font
              }
            }
          }

        }
      }

    }
  }
}

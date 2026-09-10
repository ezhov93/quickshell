import qs.config
import qs.modules.Bar.components
import qs.modules.Bar.services
import Quickshell
import Quickshell.Io
import QtQuick
Scope {
  id: barRoot
  property var theme: Theme
  property string font: Config.fontFamily
  property bool barVisible: true

  Binding { target: ResourceService; property: "active"; value: barRoot.barVisible }
  Binding { target: NetworkService; property: "active"; value: barRoot.barVisible }

  KeyboardLayout { id: keyboardLayout }

  IpcHandler {
    target: "bar"
    function toggle(): void { barRoot.barVisible = !barRoot.barVisible; }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: barRoot.barVisible

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 32
      color: barRoot.theme.bgBase

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
            theme: barRoot.theme
            font: barRoot.font
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
            color: barRoot.theme.textPrimary
            font.pixelSize: 13
            font.family: barRoot.font
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
            theme: barRoot.theme
            font: barRoot.font
          }

          // Now Playing
          MediaWidget {
            theme: barRoot.theme
            font: barRoot.font
          }

          // Volume
          VolumeWidget {
            theme: barRoot.theme
            font: barRoot.font
          }

          // Brightness
          BrightnessWidget {
            theme: barRoot.theme
            font: barRoot.font
          }

          // System Info
          SystemIndicators {
            theme: barRoot.theme
            font: barRoot.font
            onOpenNetworkSettings: NetworkService.openSettings()
          }

          // Keyboard layout of Hyprland's main keyboard
          BarButton {
            theme: barRoot.theme
            font: barRoot.font
            width: layoutText.implicitWidth + 16
            visible: keyboardLayout.label !== ""

            Accessible.role: Accessible.StaticText
            Accessible.name: "Keyboard layout: " + keyboardLayout.layoutName

            Text {
              id: layoutText
              anchors.centerIn: parent
              text: keyboardLayout.label
              color: barRoot.theme.accentPrimary
              font.pixelSize: 11
              font.family: barRoot.font
              font.bold: true
            }
          }

          // Time
          BarButton {
            theme: barRoot.theme
            font: barRoot.font
            width: timeDate.width + 16

            Row {
              id: timeDate
              anchors.centerIn: parent
              spacing: 8

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: barRoot.theme.accentPrimary
                font.pixelSize: 14
                font.family: barRoot.font
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Time.dateString
                color: barRoot.theme.textPrimary
                font.pixelSize: 12
                font.family: barRoot.font
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Time.timeString
                color: barRoot.theme.textSecondary
                font.pixelSize: 12
                font.family: barRoot.font
              }
            }
          }

        }
      }

    }
  }
}

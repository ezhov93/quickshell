import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

Scope {
  id: root
  property Theme theme: Theme
  property string font: Config.fontFamily

  property bool showVolume: false
  property bool showBrightness: false
  readonly property real volumeValue: Audio.volume
  readonly property bool volumeMuted: Audio.muted
  readonly property real brightnessValue: Brightness.value
  Connections {
    target: Audio
    function onVolumeChanged() { root.showAudio(); }
    function onMutedChanged() { root.showAudio(); }
    function onAvailableChanged() {
      if (!Audio.available) root.showVolume = false;
    }
  }

  Timer {
    id: volumeHideTimer
    interval: 1500
    onTriggered: root.showVolume = false
  }

  function showAudio() {
    if (!Audio.available) return;
    showVolume = true;
    volumeHideTimer.restart();
  }

  Connections {
    target: Brightness
    function onUpdated() {
      root.showBrightness = true;
      brightnessHideTimer.restart();
    }
  }

  Timer {
    id: brightnessHideTimer
    interval: 1500
    onTriggered: root.showBrightness = false
  }

  Variants {
    model: Quickshell.screens

    LazyLoader {
      id: osdLoader
      required property ShellScreen modelData
      active: root.showVolume || root.showBrightness

      PanelWindow {
        screen: osdLoader.modelData

        focusable: false
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        mask: Region {}

        implicitWidth: 70

        WlrLayershell {
          layer: WlrLayer.Overlay
          keyboardFocus: WlrKeyboardFocus.None
          namespace: "quickshell-osd"
        }

        anchors {
          right: true
          top: true
          bottom: true
        }

        Column {
          anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
          }
          spacing: 12

          Rectangle {
            id: volumePill
            width: 36
            height: 200
            radius: 25
            color: root.theme.bgBase
            border.color: root.theme.bgBorder
            border.width: 1
            opacity: root.showVolume ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Accessible.role: Accessible.ProgressBar
            Accessible.name: root.volumeMuted ? "Volume: muted" : "Volume: " + Math.round(root.volumeValue * 100) + "%"

            ColumnLayout {
              anchors { fill: parent; topMargin: 12; bottomMargin: 12; leftMargin: 0; rightMargin: 0 }
              spacing: 8
              Text {
                text: root.volumeMuted ? "Mute" : Math.round(root.volumeValue * 100) + "%"
                color: root.theme.textSecondary
                font.pixelSize: 10
                font.family: root.font
                Layout.alignment: Qt.AlignHCenter
              }
              Rectangle {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 8
                radius: 4
                color: root.theme.bgSurface
                border.color: root.theme.bgBorder
                border.width: 1
                clip: true
                Rectangle {
                  anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: 2 }
                  height: Math.max(0, (parent.height - 4) * Math.max(0, Math.min(1, root.volumeMuted ? 0 : root.volumeValue)))
                  radius: 3
                  color: root.volumeMuted ? root.theme.textMuted : root.theme.accentPrimary
                  Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                }
              }
              Text {
                text: root.volumeMuted || root.volumeValue <= 0 ? "󰖁" : root.volumeValue < 0.33 ? "󰕿" : root.volumeValue < 0.66 ? "󰖀" : "󰕾"
                color: root.volumeMuted ? root.theme.textMuted : root.theme.accentPrimary
                font.pixelSize: 15
                font.family: root.font
                Layout.alignment: Qt.AlignHCenter
              }
            }
          }

          Rectangle {
            id: brightnessPill
            width: 36
            height: 200
            radius: 25
            color: root.theme.bgBase
            border.color: root.theme.bgBorder
            border.width: 1
            opacity: root.showBrightness ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Accessible.role: Accessible.ProgressBar
            Accessible.name: "Brightness: " + Math.round(root.brightnessValue * 100) + "%"

            ColumnLayout {
              anchors { fill: parent; topMargin: 12; bottomMargin: 12; leftMargin: 0; rightMargin: 0 }
              spacing: 8
              Text {
                text: Math.round(root.brightnessValue * 100) + "%"
                color: root.theme.textSecondary
                font.pixelSize: 10
                font.family: root.font
                Layout.alignment: Qt.AlignHCenter
              }
              Rectangle {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 8
                radius: 4
                color: root.theme.bgSurface
                border.color: root.theme.bgBorder
                border.width: 1
                clip: true
                Rectangle {
                  anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: 2 }
                  height: Math.max(0, (parent.height - 4) * Math.max(0, Math.min(1, root.brightnessValue)))
                  radius: 3
                  color: root.theme.accentOrange
                  Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                }
              }
              Text {
                text: "󰃠"
                color: root.theme.accentOrange
                font.pixelSize: 15
                font.family: root.font
                Layout.alignment: Qt.AlignHCenter
              }
            }
          }
        }
      }
    }
  }
}

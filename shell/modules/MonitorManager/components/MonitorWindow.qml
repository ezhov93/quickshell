import qs.config
import qs.components
import qs.modules.MonitorManager.components
import qs.modules.MonitorManager.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: root
  required property var theme
  required property MonitorEditorState editor
  property string font: Config.fontFamily

  visible: editor.isOpen
  focusable: true
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "quickshell-monitors"

  exclusionMode: ExclusionMode.Ignore

  anchors { top: true; bottom: true; left: true; right: true }

  // Poll for external Hyprland changes while the editor is open.
  Timer {
    id: externalChangePollTimer
    interval: Config.monitorExternalPollInterval
    repeat: true
    running: editor.isOpen
             && !MonitorService.loading
             && !editor.isApplying
             && !canvas.isDragging
    onTriggered: MonitorService.refresh()
  }

  // Dark overlay backdrop — closes pickers; click outside card cancels
  MouseArea {
    anchors.fill: parent
    onClicked: {
      panel.modePickerOpen   = false;
      panel.mirrorPickerOpen = false;
      editor.cancelChanges();
    }

    Rectangle {
      anchors.fill: parent
      color: root.theme.bgOverlay
    }
  }

  // Main card
  Rectangle {
    anchors.centerIn: parent
    width: 960
    height: 640
    radius: 16
    color: root.theme.bgBase
    border.color: root.theme.bgBorder
    border.width: 1
    focus: true
    Keys.onEscapePressed: { if (!editor.isApplying) editor.cancelChanges(); }

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
          text: "󰍺  Monitor Manager"
          color: root.theme.accentPrimary
          font { pixelSize: 14; bold: true; family: root.font }
        }

        Item { Layout.fillWidth: true }

        // Refresh button
        IconButton {
          width: 28; height: 28
          circular:  true
          theme:     root.theme
          font:      root.font
          icon:      "󰑐"
          iconColor: MonitorService.loading ? root.theme.textMuted : root.theme.textSecondary
          enabled: !editor.isApplying
        onClicked: MonitorService.refresh()
        }
      }

      // Content: canvas + panel
      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 12

        MonitorCanvas {
          id: canvas
        enabled: !editor.isApplying
          Layout.fillWidth: true
          Layout.fillHeight: true
          monitors:      editor.editState
          selectedIndex: editor.selectedIndex
          theme:         root.theme
          font:          root.font

          onMonitorSelected: idx => editor.selectedIndex = idx
          onMonitorMoved: (idx, nx, ny) => {
            editor.updateMonitor(idx, { x: nx, y: ny });
          }
        }

        MonitorPanel {
          id: panel
        enabled: !editor.isApplying
          width: 260
          Layout.fillHeight: true
          visible: editor.selectedIndex >= 0 && editor.editState.length > 0

          monitor:     visible ? editor.editState[editor.selectedIndex] : null
          allMonitors: editor.editState
          theme:       root.theme
          font:        root.font

          onModeSelected:     mode    => editor.onModeSelected(mode)
          onScaleSelected:    scale   => editor.onScaleChanged(scale)
          onTransformChanged: t       => editor.onTransformChanged(t)
          onEnableToggled:    enabled => editor.onEnabledChanged(enabled)
          onMirrorChanged:    name    => editor.onMirrorChanged(name)
        }
      }

      // Persist warning banner
      Rectangle {
        Layout.fillWidth: true
        visible: editor.persistWarning
        height: 40
        radius: 8
        color: Qt.rgba(root.theme.accentOrange.r, root.theme.accentOrange.g, root.theme.accentOrange.b, 0.12)
        border.color: root.theme.accentOrange
        border.width: 1

        RowLayout {
          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          spacing: 8

          Text {
            Layout.fillWidth: true
            text: "Persistence disabled — add 'source = ~/.config/hypr/monitors.conf' to hyprland.conf."
            color: root.theme.accentOrange
            font { pixelSize: 11; family: root.font }
            elide: Text.ElideRight
          }

          Text {
            text: "✕"
            color: root.theme.accentOrange
            font { pixelSize: 11; family: root.font }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: editor.persistWarning = false
            }
          }
        }
      }

      // Hotplug / external change banner
      Rectangle {
        Layout.fillWidth: true
        visible: editor.hotplugDetected
        height: 40
        radius: 8
        color: Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b, 0.12)
        border.color: root.theme.accentCyan
        border.width: 1

        RowLayout {
          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          spacing: 8

          Text {
            Layout.fillWidth: true
            text: "A display was connected or disconnected."
            color: root.theme.accentCyan
            font { pixelSize: 11; family: root.font }
          }

          IconButton {
            height: 24; radius: 6
            theme:     root.theme
            font:      root.font
            label:     "Ignore"
            iconSize:  11
            iconColor: root.theme.textPrimary
            baseColor: root.theme.bgSurface
            onClicked: editor.hotplugDetected = false
          }

          IconButton {
            height: 24; radius: 6
            theme:      root.theme
            font:       root.font
            label:      "Reload layout"
            iconSize:   11
            iconColor:  root.theme.bgBase
            baseColor:  root.theme.accentCyan
            hoverColor: root.theme.accentCyan
            onClicked: {
              editor.hotplugDetected = false;
              editor.initEditState();
            }
          }
        }
      }

      // Error banner
      Rectangle {
        id: errorBanner
        Layout.fillWidth: true
        visible: editor.applyError !== ""
        height: 40
        radius: 8
        color: Qt.rgba(root.theme.accentRed.r, root.theme.accentRed.g, root.theme.accentRed.b, 0.15)
        border.color: root.theme.accentRed
        border.width: 1

        onVisibleChanged: if (visible) errorDismissTimer.restart()

        Timer {
          id: errorDismissTimer
          interval: 5000
          onTriggered: editor.applyError = ""
        }

        RowLayout {
          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          spacing: 8

          Text {
            Layout.fillWidth: true
            text: editor.applyError
            color: root.theme.accentRed
            font { pixelSize: 11; family: root.font }
            elide: Text.ElideRight
          }

          Text {
            text: "✕"
            color: root.theme.accentRed
            font { pixelSize: 11; family: root.font }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: { errorDismissTimer.stop(); editor.applyError = "" }
            }
          }
        }
      }

      // Footer
      RowLayout {
        Layout.fillWidth: true
        spacing: 16

        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "drag"
          description: "arrange"
        }

        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "click"
          description: "select"
        }

        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "esc"
          description: "close"
        }

        Item { Layout.fillWidth: true }

        Text {
          visible: MonitorService.loading
          text: "󰑐  Loading…"
          color: root.theme.textMuted
          font { pixelSize: 11; family: root.font }
        }

        Rectangle {
          width: applyText.width + 24; height: 32; radius: 8
          color: (editor.isApplying || MonitorService.loading || editor.hasOverlap)
                 ? root.theme.bgSurface : root.theme.accentPrimary
          border.color: root.theme.bgBorder
          border.width: 1
          opacity: (editor.isApplying || MonitorService.loading || editor.hasOverlap) ? 0.5 : 1.0

          Text {
            id: applyText
            anchors.centerIn: parent
            text: editor.isApplying ? "Applying…" : "Apply"
            color: (editor.isApplying || MonitorService.loading || editor.hasOverlap)
                   ? root.theme.textMuted : root.theme.bgBase
            font { pixelSize: 12; bold: true; family: root.font }
          }
          MouseArea {
            anchors.fill: parent
            cursorShape: (editor.isApplying || MonitorService.loading || editor.hasOverlap)
                         ? Qt.ArrowCursor : Qt.PointingHandCursor
            enabled: !editor.isApplying && !MonitorService.loading && !editor.hasOverlap
            onClicked: editor.applyChanges()
          }
        }
      }
    }
  }
}

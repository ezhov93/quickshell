import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import qs.config

Item {
  id: root

  property var monitor:     null
  property list<var> allMonitors: []
  required property Theme theme
  required property string font

  property bool modePickerOpen:   false
  property bool mirrorPickerOpen: false

  signal modeSelected(string mode)
  signal scaleSelected(real scale)      // not scaleChanged — conflicts with Item.scale built-in
  signal transformChanged(int transform)
  signal enableToggled(bool enabled)    // not enabledChanged — conflicts with Item.enabled built-in
  signal mirrorChanged(string mirrorOf)

  onMonitorChanged: {
    modePickerOpen   = false;
    mirrorPickerOpen = false;
    modeDropdown.close();
    mirrorDropdown.close();
  }

  Popup {
    id: modeDropdown
    parent: modePill
    x: 0
    y: modePill.height + 4
    width: modePill.width
    padding: 1  // background border is drawn inward, so contentItem overlaps it without this
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    background: Rectangle {
      radius: 8
      color: root.theme.bgSurface
      border.color: root.theme.accentPrimary
      border.width: 1
    }

    contentItem: ListView {
      id: modeList
      implicitHeight: Math.min(contentHeight + 2, 180)
      model: root.monitor?.availableModes ?? []
      boundsBehavior: Flickable.StopAtBounds
      clip: true

      delegate: Rectangle {
        required property string modelData
        width: modeList.width
        height: 28
        radius: 4
        color: modelData === (root.monitor?.selectedMode ?? "") ? root.theme.accentPrimary : "transparent"

        Row {
          spacing: 0

          anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
          Text {
            text: modelData.split("@")[0]
            color: modelData === (root.monitor?.selectedMode ?? "") ? root.theme.bgBase : root.theme.textPrimary
            width: parent.width - rateText.width
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 11; family: root.font }
          }
          Text {
            id: rateText
            text: "@" + (modelData.split("@")[1] ?? "")
            color: modelData === (root.monitor?.selectedMode ?? "") ? root.theme.bgBase : root.theme.textMuted
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 11; family: root.font }
          }
        }

        MouseArea {
          cursorShape: Qt.PointingHandCursor
          anchors.fill: parent
          onClicked: {
            root.modeSelected(modelData);
            modeDropdown.close();
          }
        }
      }
    }
    onOpened: root.modePickerOpen   = true
    onClosed: root.modePickerOpen   = false

  }

  Popup {
    id: mirrorDropdown
    parent: mirrorPill
    x: 0
    y: mirrorPill.height + 4
    width: mirrorPill.width
    padding: 1  // background border is drawn inward, so contentItem overlaps it without this
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    background: Rectangle {
      radius: 8
      color: root.theme.bgSurface
      border.color: root.theme.accentPrimary
      border.width: 1
    }

    contentItem: ListView {
      id: mirrorList
      implicitHeight: Math.min(contentHeight + 2, 150)
      model: {
        if (root.monitor === null) return [];
        const opts = [""];
        for (const m of root.allMonitors) {
          if (m.name !== root.monitor.name) opts.push(m.name);
        }
        return opts;
      }
      boundsBehavior: Flickable.StopAtBounds
      clip: true

      delegate: Rectangle {
        required property string modelData
        width: mirrorList.width
        height: 28
        radius: 4
        color: modelData === (root.monitor?.mirrorOf ?? "") ? root.theme.accentPrimary : "transparent"

        Text {
          text: modelData === "" ? "None" : modelData
          color: modelData === (root.monitor?.mirrorOf ?? "")
                 ? root.theme.bgBase
                 : (modelData === "" ? root.theme.textMuted : root.theme.textPrimary)
          verticalAlignment: Text.AlignVCenter
          anchors { fill: parent; leftMargin: 10 }
          font { pixelSize: 11; family: root.font }
        }

        MouseArea {
          cursorShape: Qt.PointingHandCursor
          anchors.fill: parent
          onClicked: {
            root.mirrorChanged(modelData);
            mirrorDropdown.close();
          }
        }
      }
    }
    onOpened: root.mirrorPickerOpen = true
    onClosed: root.mirrorPickerOpen = false

  }

  ScrollView {
    clip: true
    contentWidth: availableWidth
    visible: root.monitor !== null

    anchors.fill: parent
    ColumnLayout {
      width: root.width
      spacing: 12

      Text {
        text: root.monitor?.name ?? ""
        color: root.theme.textPrimary
        Layout.fillWidth: true
        font { pixelSize: 14; bold: true; family: root.font }
      }
      Text {
        text: root.monitor?.description ?? ""
        color: root.theme.textMuted
        elide: Text.ElideRight
        Layout.fillWidth: true
        font { pixelSize: 11; family: root.font }
      }

      Divider { color: root.theme.bgBorder }

      Text {
        text: "Resolution"
        color: root.theme.textSecondary
        font { pixelSize: 11; family: root.font }
      }

      Rectangle {
        id: modePill
        radius: 8
        color: root.theme.bgSurface
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        border.color: root.modePickerOpen ? root.theme.accentPrimary : root.theme.bgBorder
        border.width: 1

        Row {
          spacing: 0

          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          Text {
            text: (root.monitor?.selectedMode ?? "").replace("Hz", "")
            color: root.theme.textPrimary
            width: parent.width - 20
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 12; family: root.font }
          }
          Text {
            text: root.modePickerOpen ? "▴" : "▾"
            color: root.theme.textMuted
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 16; family: root.font }
          }
        }

        MouseArea {
          cursorShape: Qt.PointingHandCursor
          anchors.fill: parent
          onClicked: {
            if (root.modePickerOpen) {
              modeDropdown.close();
            } else {
              mirrorDropdown.close();
              modeDropdown.open();
            }
          }
        }
      }

      Divider { color: root.theme.bgBorder }

      Text {
        text: "Scale"
        color: root.theme.textSecondary
        font { pixelSize: 11; family: root.font }
      }

      Flow {
        spacing: 4

        Layout.fillWidth: true
        Repeater {
          model: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
          Rectangle {
            required property real modelData
            width: 38; height: 26; radius: 6
            color: Math.abs((root.monitor?.scale ?? -1) - modelData) < 0.01 ? root.theme.accentPrimary : root.theme.bgSurface
            border.color: root.theme.bgBorder
            border.width: 1

            Text {
              text: modelData + "×"
              color: Math.abs((root.monitor?.scale ?? -1) - modelData) < 0.01 ? root.theme.bgBase : root.theme.textPrimary
              anchors.centerIn: parent
              font { pixelSize: 10; family: root.font }
            }

            MouseArea {
              cursorShape: Qt.PointingHandCursor
              anchors.fill: parent
              onClicked: root.scaleSelected(modelData)
            }
          }
        }
      }

      Divider { color: root.theme.bgBorder }

      Text {
        text: "Rotation"
        color: root.theme.textSecondary
        font { pixelSize: 11; family: root.font }
      }

      Row {
        spacing: 4

        Repeater {
          model: [
            { t: 0, label: "0°",   icon: "󰍹" },
            { t: 1, label: "90°",  icon: "󰑧" },
            { t: 2, label: "180°", icon: "󱃨" },
            { t: 3, label: "270°", icon: "󰑥" },
          ]
          Rectangle {
            required property var modelData
            width: 52; height: 26; radius: 6
            color: (root.monitor?.transform ?? -1) === modelData.t ? root.theme.accentPrimary : root.theme.bgSurface
            border.color: root.theme.bgBorder
            border.width: 1

            Row {
              spacing: 4
              anchors.centerIn: parent
              Text {
                text: modelData.icon
                color: (root.monitor?.transform ?? -1) === modelData.t ? root.theme.bgBase : root.theme.textMuted
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: 13; family: root.font }
              }
              Text {
                text: modelData.label
                color: (root.monitor?.transform ?? -1) === modelData.t ? root.theme.bgBase : root.theme.textPrimary
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: 10; family: root.font }
              }
            }

            MouseArea {
              cursorShape: Qt.PointingHandCursor
              anchors.fill: parent
              onClicked: root.transformChanged(modelData.t)
            }
          }

        }
      }

      Divider { color: root.theme.bgBorder }

      Text {
        text: "Mirror of"
        color: root.theme.textSecondary
        font { pixelSize: 11; family: root.font }
      }

      Rectangle {
        id: mirrorPill
        radius: 8
        color: root.theme.bgSurface
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        border.color: root.mirrorPickerOpen ? root.theme.accentPrimary : root.theme.bgBorder
        border.width: 1

        Row {
          spacing: 0

          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          Text {
            text: (root.monitor?.mirrorOf ?? "") === "" ? "None" : (root.monitor?.mirrorOf ?? "")
            color: (root.monitor?.mirrorOf ?? "") === "" ? root.theme.textMuted : root.theme.textPrimary
            width: parent.width - 20
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 12; family: root.font }
          }
          Text {
            text: root.mirrorPickerOpen ? "▴" : "▾"
            color: root.theme.textMuted
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 16; family: root.font }
          }
        }

        MouseArea {
          cursorShape: Qt.PointingHandCursor
          anchors.fill: parent
          onClicked: {
            if (root.mirrorPickerOpen) {
              mirrorDropdown.close();
            } else {
              modeDropdown.close();
              mirrorDropdown.open();
            }
          }
        }
      }

      Divider { color: root.theme.bgBorder }

      Rectangle {
        radius: 8
        color: (root.monitor?.disabled ?? true) ? root.theme.bgSurface : root.theme.accentGreen
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        border.color: root.theme.bgBorder
        border.width: 1

        Row {
          spacing: 8
          anchors.centerIn: parent
          Text {
            text: (root.monitor?.disabled ?? true) ? "" : ""
            color: (root.monitor?.disabled ?? true) ? root.theme.textMuted : root.theme.bgBase
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 14; family: root.font }
          }
          Text {
            text: (root.monitor?.disabled ?? true) ? "Disabled" : "Enabled"
            color: (root.monitor?.disabled ?? true) ? root.theme.textMuted : root.theme.bgBase
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 12; bold: true; family: root.font }
          }
        }

        MouseArea {
          cursorShape: Qt.PointingHandCursor
          anchors.fill: parent
          onClicked: {
            if (root.monitor !== null) root.enableToggled(root.monitor.disabled);
          }
        }
      }

      Item { Layout.preferredHeight: 8 }
      // Monitor identity
      // Divider
      // Resolution section
      // Collapsed mode pill
      // Divider
      // Scale section
      // Divider
      // Rotation section
      // Divider
      // Mirror section
      // Mirror collapsed pill
      // Divider
      // Enable / Disable toggle
      // Bottom spacer
    }
    // ScrollView is visible but content guards itself against null monitor
  }
  // Not required — intentionally null when no monitor is selected
  // Close open pickers when the selected monitor changes
  // ── Mode dropdown overlay ────────────────────────────────────────────────
  // ── Mirror dropdown overlay ──────────────────────────────────────────────
  // All children use optional chaining (monitor?.X) so bindings are safe when monitor is null
}

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.components
import qs.config
import qs.modules.AppLauncher.services
PanelWindow {
  id: root
  required property var theme
  property string font: Config.fontFamily
  signal closeRequested()
  Component.onCompleted: searchInput.forceActiveFocus()

  property int selectedIndex: -1

  ScriptModel {
    id: filteredApps
    objectProp: "id"
    values: {
      return SearchIndex.search(searchInput.text);
    }
    onValuesChanged: root.reconcileSelection()
  }

  visible: true
  focusable: true
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "quickshell-launcher"

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

  // Centered launcher box
  Rectangle {
    id: launcherBox
    anchors.centerIn: parent
    width: 580
    height: 480
    radius: 16
    color: root.theme.bgBase
    border.color: root.theme.bgBorder
    border.width: 1

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 12

      // Header
      Text {
        text: "  Applications"
        color: root.theme.accentPrimary
        font.pixelSize: 14
        font.family: root.font
        font.bold: true
      }

      // Search bar
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: 10
        color: root.theme.bgSurface
        border.color: searchInput.activeFocus ? root.theme.accentPrimary : root.theme.bgBorder
        border.width: 1

        Behavior on border.color {
          ColorAnimation { duration: 150 }
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 14
          anchors.rightMargin: 14
          spacing: 10

          Text {
            text: ""
            color: root.theme.textMuted
            font.pixelSize: 16
            font.family: root.font
            Layout.alignment: Qt.AlignVCenter
          }

          TextInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            color: root.theme.textPrimary
            font.pixelSize: 15
            font.family: root.font
            clip: true
            focus: true
            Accessible.role: Accessible.EditableText
            Accessible.name: "Search applications"

            Text {
              anchors.fill: parent
              text: "Type to search..."
              color: root.theme.textMuted
              font: parent.font
              visible: !parent.text && !parent.activeFocus
              verticalAlignment: Text.AlignVCenter
            }

            onTextChanged: root.resetSelectionForQuery()

            Keys.onEscapePressed: root.closeRequested()

            Keys.onPressed: event => {
              if (event.key === Qt.Key_Down) {
                event.accepted = true;
                root.moveSelection(1);
              } else if (event.key === Qt.Key_Up) {
                event.accepted = true;
                root.moveSelection(-1);
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true;
                root.launchSelected();
              } else if (event.key === Qt.Key_Tab) {
                event.accepted = true;
                root.moveSelection(1);
              }
            }
          }
        }
      }

      // Results count
      Text {
        text: resultsList.count + " application" + (resultsList.count !== 1 ? "s" : "")
        color: root.theme.textMuted
        font.pixelSize: 11
        font.family: root.font
      }

      // App list
      ListView {
        id: resultsList
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: filteredApps
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: root.selectedIndex
        highlightMoveDuration: 150
        highlightMoveVelocity: -1

        highlight: Rectangle {
          radius: 8
          color: root.theme.bgSelected
          visible: root.selectedIndex >= 0

          Rectangle {
            width: 3
            height: 24
            radius: 2
            color: root.theme.accentPrimary
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        delegate: LauncherEntry {
          required property var modelData
          required property int index

          width: resultsList.width
          height: implicitHeight
          entry: modelData
          entryIndex: index
          selected: root.selectedIndex === index
          theme: root.theme
          font: root.font
          onActivated: entry => root.launchApp(entry)
          onHovered: index => root.selectIndex(index)
        }

        // Empty state
        Text {
          anchors.centerIn: parent
          text: "  No applications found"
          color: root.theme.textMuted
          font.pixelSize: 14
          font.family: root.font
          visible: resultsList.count === 0 && searchInput.text !== ""
        }
      }

      // Footer hint
      RowLayout {
        Layout.fillWidth: true
        spacing: 16

        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "↑↓"
          description: "navigate"
        }

        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "⏎"
          description: "launch"
        }

        ShortcutHint {
          theme: root.theme
          font: root.font
          shortcut: "esc"
          description: "close"
        }

        Item { Layout.fillWidth: true }
      }
    }
  }

  function selectIndex(index): void {
    const count = filteredApps.values.length;
    root.selectedIndex = count === 0 ? -1 : Math.max(0, Math.min(index, count - 1));
  }

  function reconcileSelection(): void {
    if (searchInput.text === "") {
      root.selectedIndex = -1;
      return;
    }
    root.selectIndex(root.selectedIndex < 0 ? 0 : root.selectedIndex);
  }

  function resetSelectionForQuery(): void {
    root.selectedIndex = searchInput.text === "" || filteredApps.values.length === 0 ? -1 : 0;
  }

  function moveSelection(delta): void {
    const previousIndex = root.selectedIndex;
    root.selectIndex(previousIndex < 0 ? 0 : previousIndex + delta);
    if (root.selectedIndex >= 0)
      resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
  }

  function launchSelected(): void {
    const entry = root.selectedIndex >= 0 && root.selectedIndex < filteredApps.values.length
      ? filteredApps.values[root.selectedIndex]
      : null;
    if (entry) root.launchApp(entry);
  }

  function launchApp(entry): void {
    if (SearchIndex.launch(entry)) root.closeRequested();
  }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.components
import qs.config
import qs.modules.AppLauncher.services

Rectangle {
  id: root

  required property Theme theme
  property string font: Config.fontFamily
  property alias query: searchInput.text
  property int selectedIndex: -1
  signal closeRequested()
  signal launchRequested(var entry)

  implicitWidth: 580
  implicitHeight: 480
  radius: 16
  color: root.theme.bgBase
  border.color: root.theme.bgBorder
  border.width: 1

  Component.onCompleted: searchInput.forceActiveFocus()

  ScriptModel {
    id: filteredApps
    objectProp: "id"
    values: root.searchResults
    onValuesChanged: root.reconcileSelection()
  }

  ColumnLayout {
    spacing: 12

    anchors.fill: parent
    anchors.margins: 16
    Text {
      text: "  Applications"
      color: root.theme.accentPrimary
      font {
        pixelSize: 14
        family: root.font
        bold: true
      }
    }

    Rectangle {
      radius: 10
      color: root.theme.bgSurface
      border.color: searchInput.activeFocus ? root.theme.accentPrimary : root.theme.bgBorder
      border.width: 1
      Layout.fillWidth: true
      Layout.preferredHeight: 44

      Behavior on border.color {
        ColorAnimation { duration: 150 }
      }

      RowLayout {
        spacing: 10

        anchors {
          fill: parent
          leftMargin: 14
          rightMargin: 14
        }
        Text {
          text: ""
          color: root.theme.textMuted
          font.pixelSize: 16
          font.family: root.font
          Layout.alignment: Qt.AlignVCenter
        }

        TextInput {
          id: searchInput
          color: root.theme.textPrimary
          clip: true
          focus: true
          font.pixelSize: 15
          font.family: root.font
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter
          Accessible.role: Accessible.EditableText
          Accessible.name: "Search applications"

          Keys.onPressed: event => root.handleKey(event)
          onTextChanged: root.resetSelectionForQuery()
          Text {
            text: "Type to search..."
            color: root.theme.textMuted
            font: parent.font
            visible: !parent.text && !parent.activeFocus
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
          }

        }
      }
    }

    Text {
      text: results.count + " application" + (results.count !== 1 ? "s" : "")
      color: root.theme.textMuted
      font.pixelSize: 11
      font.family: root.font
    }

    LauncherResults {
      id: results
      theme: root.theme
      font: root.font
      entriesModel: filteredApps
      selectedIndex: root.selectedIndex
      query: searchInput.text
      Layout.fillWidth: true
      Layout.fillHeight: true
      onActivated: entry => root.launchRequested(entry)
      onHovered: index => root.selectIndex(index)
    }

    RowLayout {
      spacing: 16

      Layout.fillWidth: true
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
    results.positionSelected(root.selectedIndex);
  }

  function launchSelected(): void {
    const entry = root.selectedIndex >= 0 && root.selectedIndex < filteredApps.values.length
      ? filteredApps.values[root.selectedIndex]
      : null;
    if (entry) root.launchRequested(entry);
  }

  function handleKey(event): void {
    if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
      event.accepted = true;
      root.moveSelection(1);
    } else if (event.key === Qt.Key_Up) {
      event.accepted = true;
      root.moveSelection(-1);
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      event.accepted = true;
      root.launchSelected();
    } else if (event.key === Qt.Key_Escape) {
      event.accepted = true;
      root.closeRequested();
    }
  }
  readonly property int resultCount: filteredApps.values.length
  readonly property bool searchHasFocus: searchInput.activeFocus
  readonly property var searchResults: LauncherService.search(searchInput.text)

}

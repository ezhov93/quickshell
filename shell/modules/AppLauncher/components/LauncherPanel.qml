pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.components
import qs.config
import qs.modules.AppLauncher.services

Rectangle {
  id: root

  required property var theme
  property string font: Config.fontFamily
  property alias query: searchInput.text
  property int selectedIndex: -1
  readonly property int resultCount: filteredApps.values.length
  readonly property bool searchHasFocus: searchInput.activeFocus
  readonly property var searchResults: LauncherService.search(searchInput.text)

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
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12

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
        anchors {
          fill: parent
          leftMargin: 14
          rightMargin: 14
        }
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
          Keys.onPressed: event => root.handleKey(event)
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
      Layout.fillWidth: true
      Layout.fillHeight: true
      theme: root.theme
      font: root.font
      entriesModel: filteredApps
      selectedIndex: root.selectedIndex
      query: searchInput.text
      onActivated: entry => root.launchRequested(entry)
      onHovered: index => root.selectIndex(index)
    }

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
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

Singleton {
  id: root

  property string label: ""
  property string layoutName: ""
  property string keyboardName: ""
  property list<string> layouts: []
  property var layoutLabels: ({})
  property bool loading: false
  property bool pending: false
  Component.onCompleted: refreshTimer.start()

  Timer {
    id: refreshTimer
    interval: 50
    onTriggered: root.refresh()
  }

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "activelayout") {
        if (root.layoutLabels[root.layoutName]) {
          root.label = root.layoutLabels[root.layoutName];
        } else {
          root.label = root.layoutName.slice(0, 3).toUpperCase();
          refreshTimer.restart();
        }
        root.layoutLabels = ({});
        const parts = event.parse(2);
        if (parts[0] !== root.keyboardName) return;

        root.layoutName = parts[1] || "";
        if (root.loading) root.pending = true;
      } else if (["configreloaded", "deviceadded", "deviceremoved"].includes(event.name)) {
        refreshTimer.restart();
      }
    }
  }
  function setLayout(name, code = "") {
    layoutName = name;
    label = code === "us" || code === "gb" ? "EN" : code ? code.toUpperCase() : name.slice(0, 3).toUpperCase();
    if (name && code) layoutLabels[name] = label;
  }

  function refresh() {
    if (loading) {
      pending = true;
      return;
    }

    HyprlandClient.request("j/devices", (text, error) => {
      try {
        if (error) throw new Error(error);
        const keyboards = JSON.parse(text).keyboards || [];
        const keyboard = keyboards.find(candidate => candidate.main) || keyboards[0];
        keyboardName = keyboard?.name ?? "";
        layouts = (keyboard?.layout || "").split(",").map(layout => layout.trim());
        setLayout(keyboard?.active_keymap ?? "", layouts[keyboard?.active_layout_index] || "");
      } catch (error) {
        setLayout("");
        console.warn("Failed to read keyboard layout:", error);
      }

      if (pending) {
        pending = false;
        refreshTimer.restart();
      }
      loading = false;
    });
    loading = true;
  }

}

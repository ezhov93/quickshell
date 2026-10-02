pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.services

Singleton {
  id: root

  property string label: ""
  property string layoutName: ""
  property string keyboardName: ""
  property var layouts: []
  property var layoutLabels: ({})
  property bool loading: false
  property bool pending: false

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

    loading = true;
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

      loading = false;
      if (pending) {
        pending = false;
        refreshTimer.restart();
      }
    });
  }

  Timer {
    id: refreshTimer
    interval: 50
    onTriggered: root.refresh()
  }

  Component.onCompleted: refreshTimer.start()

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "activelayout") {
        const parts = event.parse(2);
        if (parts[0] !== root.keyboardName) return;

        root.layoutName = parts[1] || "";
        if (root.layoutLabels[root.layoutName]) {
          root.label = root.layoutLabels[root.layoutName];
        } else {
          root.label = root.layoutName.slice(0, 3).toUpperCase();
          refreshTimer.restart();
        }
        if (root.loading) root.pending = true;
      } else if (["configreloaded", "deviceadded", "deviceremoved"].includes(event.name)) {
        root.layoutLabels = ({});
        refreshTimer.restart();
      }
    }
  }
}

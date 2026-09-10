import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.services

Scope {
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
    if (loading) { pending = true; return; }
    loading = true;
    HyprlandClient.request("j/devices", (text, error) => {
      try {
        if (error) throw new Error(error);
        const keyboards = JSON.parse(text).keyboards || [];
        const keyboard = keyboards.find(k => k.main) || keyboards[0];
        keyboardName = keyboard?.name ?? "";
        layouts = (keyboard?.layout || "").split(",").map(s => s.trim());
        setLayout(keyboard?.active_keymap ?? "", layouts[keyboard?.active_layout_index] || "");
      } catch (e) {
        setLayout("");
        console.warn("Failed to read keyboard layout:", e);
      }
      loading = false;
      if (pending) { pending = false; refreshTimer.restart(); }
    });
  }

  Timer { id: refreshTimer; interval: 50; onTriggered: root.refresh() }
  Component.onCompleted: refreshTimer.start()
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "activelayout") {
        const parts = event.parse(2);
        if (parts[0] !== root.keyboardName) return;
        root.layoutName = parts[1] || "";
        // Cache the exact short code after the first observation of each layout.
        if (root.layoutLabels[root.layoutName]) root.label = root.layoutLabels[root.layoutName];
        else { root.label = root.layoutName.slice(0, 3).toUpperCase(); refreshTimer.restart(); }
        if (root.loading) root.pending = true;
      } else if (["configreloaded", "deviceadded", "deviceremoved"].includes(event.name)) {
        root.layoutLabels = ({});
        refreshTimer.restart();
      }
    }
  }
}

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Scope {
  id: root

  property string label: ""
  property string layoutName: ""

  // Coalesce events and repeat a read if the layout changed during it.
  Timer {
    id: refreshTimer
    interval: 50
    onTriggered: {
      if (devicesProc.running) restart();
      else devicesProc.running = true;
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (["activelayout", "configreloaded", "deviceadded", "deviceremoved"].includes(event.name))
        refreshTimer.restart();
    }
  }

  Process {
    id: devicesProc
    command: ["hyprctl", "-j", "devices"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const keyboards = JSON.parse(text).keyboards || [];
          const keyboard = keyboards.find(k => k.main) || keyboards[0];
          root.layoutName = keyboard ? keyboard.active_keymap || "" : "";
          const layouts = keyboard ? (keyboard.layout || "").split(",") : [];
          const code = keyboard ? (layouts[keyboard.active_layout_index] || "").trim() : "";
          root.label = code === "us" || code === "gb" ? "EN"
            : code ? code.toUpperCase() : root.layoutName.slice(0, 3).toUpperCase();
        } catch (e) {
          root.label = "";
          root.layoutName = "";
          console.warn("Failed to read keyboard layout:", e);
        }
      }
    }
  }
}

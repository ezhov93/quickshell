pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
  readonly property var workspaces: Hyprland.workspaces
  readonly property string activeWindowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""

  function activateWorkspace(workspace): void {
    if (workspace) workspace.activate();
  }
}

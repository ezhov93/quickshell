pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
  id: root

  function activateWorkspace(workspace): void {
    if (workspace) workspace.activate();
  }
  readonly property var workspaces: Hyprland.workspaces
  readonly property string activeWindowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""

}

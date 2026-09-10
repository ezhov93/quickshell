pragma Singleton

import Quickshell
import Quickshell.Services.SystemTray

Singleton {
  readonly property var items: SystemTray.items

  function activateItem(item): void {
    if (item) item.activate();
  }

  function secondaryActivateItem(item): void {
    if (item) item.secondaryActivate();
  }
}

pragma Singleton

import Quickshell
import Quickshell.Services.SystemTray

Singleton {
  id: root

  function activateItem(item): void {
    if (item) item.activate();
  }

  function secondaryActivateItem(item): void {
    if (item) item.secondaryActivate();
  }
  readonly property var items: SystemTray.items

}

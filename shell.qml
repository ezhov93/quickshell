//@ pragma UseQApplication
//@ pragma Env QT_QPA_PLATFORMTHEME=gtk3
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import Quickshell.Io
import QtQuick

import "modules/Bar"
import "modules/AppLauncher"
import "modules/Notifications"
import "modules/Wallpaper"
import "modules/Osd"
import "modules/MonitorManager"
import "modules/IdleInhibitor"

Scope {
  Bar {}
  AppLauncher {}
  NotificationPopup {}
  WallpaperManager {}
  OSD {}
  MonitorManager {}
  CaffeineToggle {}
}

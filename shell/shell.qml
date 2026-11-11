//@ pragma UseQApplication
//@ pragma Env QT_QPA_PLATFORMTHEME=gtk3
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell

import qs.modules.Bar
import qs.modules.AppLauncher
import qs.modules.Notifications
import qs.modules.Wallpaper
import qs.modules.Osd
import qs.modules.MonitorManager
import qs.modules.IdleInhibitor

Scope {
  id: root

  Bar {}
  AppLauncher {}
  Notifications {}
  Wallpaper {}
  Osd {}
  MonitorManager {}
  IdleInhibitor {}
}

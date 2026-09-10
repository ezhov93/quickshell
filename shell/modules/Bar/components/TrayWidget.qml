import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.Bar.services

Rectangle {
  id: root
  required property var theme
  required property string font

  implicitHeight: 24
  implicitWidth: trayIcons.implicitWidth + 4
  radius: 12
  color: root.theme.bgSurface

  RowLayout {
    id: trayIcons
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: TrayService.items

      MouseArea {
        id: trayDelegate
        required property var modelData

        Accessible.role: Accessible.Button
        Accessible.name: modelData.tooltipTitle || modelData.title || "System tray item"

        Layout.preferredWidth: 24
        Layout.preferredHeight: 24

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: (mouse) => {
          if (mouse.button === Qt.LeftButton) {
            TrayService.activateItem(modelData)
          } else if (mouse.button === Qt.RightButton) {
            if (modelData.hasMenu) {
              menuAnchor.open()
            }
          } else if (mouse.button === Qt.MiddleButton) {
            TrayService.secondaryActivateItem(modelData)
          }
        }

        IconImage {
          anchors.centerIn: parent
          source: trayDelegate.modelData.icon
          implicitSize: 16
        }

        QsMenuAnchor {
          id: menuAnchor
          menu: trayDelegate.modelData.menu

          anchor.window: trayDelegate.QsWindow.window
          anchor.adjustment: PopupAdjustment.Flip
          anchor.onAnchoring: {
            const window = trayDelegate.QsWindow.window;
            const widgetRect = window.contentItem.mapFromItem(
              trayDelegate, 0, trayDelegate.height,
              trayDelegate.width, trayDelegate.height);
            menuAnchor.anchor.rect = widgetRect;
          }
        }
      }
    }
  }
}

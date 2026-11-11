import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.Bar.services

BarPill {
  id: root
  implicitHeight: 24
  implicitWidth: trayIcons.implicitWidth + 4

  RowLayout {
    id: trayIcons
    spacing: 2

    anchors.centerIn: parent
    Repeater {
      model: TrayService.items

      MouseArea {
        id: trayDelegate
        required property var modelData
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        Accessible.role: Accessible.Button
        Accessible.name: modelData.tooltipTitle || modelData.title || "System tray item"

        Layout.preferredWidth: 24
        Layout.preferredHeight: 24

        onClicked: (mouse) => {
          if (mouse.button === Qt.LeftButton) {
            if (modelData.hasMenu) {
              menuAnchor.open()
            }
          } else if (mouse.button === Qt.MiddleButton) {
            TrayService.activateItem(modelData)
          } else if (mouse.button === Qt.RightButton) {
            TrayService.secondaryActivateItem(modelData)
          }
        }

        IconImage {
          source: trayDelegate.modelData.icon
          implicitSize: 16
          anchors.centerIn: parent
        }

        QsMenuAnchor {
          id: menuAnchor
          menu: trayDelegate.modelData.menu

          anchor.window: trayDelegate.QsWindow.window
          anchor.adjustment: PopupAdjustment.Flip
          anchor.onAnchoring: {
            const widgetRect = trayDelegate.QsWindow.contentItem.mapFromItem(
              trayDelegate, 0, trayDelegate.height,
              trayDelegate.width, trayDelegate.height);
            menuAnchor.anchor.rect = widgetRect;
          }
        }
      }
    }
  }
}

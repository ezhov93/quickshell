import Quickshell
import QtQuick

PanelWindow {
  id: root

  required property var modelData
  required property var theme
  required property string font

  screen: modelData

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 32
  color: root.theme.bgBase

  Item {
    anchors {
      fill: parent
      leftMargin: 10
      rightMargin: 10
    }

    Row {
      id: leftSection
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      WorkspaceSwitcher {
        theme: root.theme
        font: root.font
      }
    }

    ActiveWindowWidget {
      anchors {
        left: leftSection.right
        right: rightSection.left
        leftMargin: 12
        rightMargin: 12
      }
      height: parent.height
      theme: root.theme
      font: root.font
    }

    Row {
      id: rightSection
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      TrayWidget {
        theme: root.theme
        font: root.font
      }

      MediaWidget {
        theme: root.theme
        font: root.font
      }

      VolumeWidget {
        theme: root.theme
        font: root.font
      }

      BrightnessWidget {
        theme: root.theme
        font: root.font
      }

      CpuWidget {
        theme: root.theme
        font: root.font
      }

      MemoryWidget {
        theme: root.theme
        font: root.font
      }

      TemperatureWidget {
        theme: root.theme
        font: root.font
      }

      NetworkWidget {
        theme: root.theme
        font: root.font
      }

      BatteryWidget {
        theme: root.theme
        font: root.font
      }

      KeyboardLayoutWidget {
        theme: root.theme
        font: root.font
      }

      ClockWidget {
        theme: root.theme
        font: root.font
      }
    }
  }
}

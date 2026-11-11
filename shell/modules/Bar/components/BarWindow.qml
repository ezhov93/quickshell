import QtQuick
import Quickshell
import qs.config

PanelWindow {
  id: root

  required property ShellScreen modelData
  required property Theme theme
  required property string font

  screen: modelData
  implicitHeight: 32
  color: root.theme.bgBase

  anchors {
    top: true
    left: true
    right: true
  }

  Item {
    anchors {
      fill: parent
      leftMargin: 10
      rightMargin: 10
    }

    Row {
      id: leftSection
      spacing: 8

      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      WorkspaceSwitcher {
        theme: root.theme
        font: root.font
      }
    }

    ActiveWindowWidget {
      height: parent.height
      theme: root.theme
      font: root.font
      anchors {
        left: leftSection.right
        right: rightSection.left
        leftMargin: 12
        rightMargin: 12
      }
    }

    Row {
      id: rightSection
      spacing: 8

      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
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

pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
  readonly property var device: UPower.displayDevice
  readonly property bool available: device && device.isLaptopBattery && device.isPresent
  readonly property real charge: available ? device.percentage : NaN
  readonly property bool charging: available && device.state === UPowerDeviceState.Charging
}

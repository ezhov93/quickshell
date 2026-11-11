import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.config
import qs.modules.Bar.services

PopupWindow {
  id: root

  required property Item anchorItem
  required property Theme theme
  required property string font
  property WifiNetwork selectedNetwork: null
  property bool passwordPromptOpen: false
  property bool focusReady: false

  signal closedByUser()

  visible: false
  grabFocus: true
  color: "transparent"
  implicitWidth: 380
  implicitHeight: 480

  onVisibleChanged: {
    if (visible) {
      focusReady = false;
      NetworkService.beginWifiPopover();
      panel.forceActiveFocus();
      Qt.callLater(() => focusReady = true);
    } else {
      focusReady = false;
      NetworkService.endWifiPopover();
      closePasswordPrompt();
      closedByUser();
    }
  }

  onClosed: {
    if (focusReady) closePopover();
  }

  Component.onDestruction: NetworkService.endWifiPopover()

  anchor {
    item: anchorItem
    edges: Edges.Bottom | Edges.Right
    gravity: Edges.Bottom | Edges.Left
    adjustment: PopupAdjustment.All
  }

  Rectangle {
    id: panel
    color: root.theme.bgBase
    radius: 10
    activeFocusOnTab: true

    anchors.fill: parent
    border.color: root.theme.bgBorder
    border.width: 1
    Keys.onEscapePressed: event => {
      if (root.passwordPromptOpen) root.closePasswordPrompt();
      else root.closePopover();
      event.accepted = true;
    }

    ColumnLayout {
      spacing: 8

      anchors.fill: parent
      anchors.margins: 10
      RowLayout {
        Layout.fillWidth: true

        Text {
          text: qsTr("Wi-Fi")
          color: root.theme.textPrimary
          font.family: root.font
          font.pixelSize: 15
          Layout.fillWidth: true
        }

        Switch {
          checked: NetworkService.wifiEnabled
          enabled: NetworkService.wifiHardwareEnabled
          onToggled: NetworkService.setWifiEnabled(checked)
        }
      }

      ScrollView {
        id: scrollArea
        clip: true
        contentWidth: availableWidth
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 0
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
          width: scrollArea.availableWidth
          spacing: 8

          Text {
            visible: !NetworkService.wifiAvailable
            text: qsTr("Wi-Fi device is unavailable")
            color: root.theme.textMuted
            wrapMode: Text.WordWrap
            font.family: root.font
            font.pixelSize: 12
            Layout.fillWidth: true
          }

          Text {
            visible: NetworkService.wifiAvailable && !NetworkService.wifiHardwareEnabled
            text: qsTr("Wi-Fi is disabled by hardware")
            color: root.theme.accentOrange
            wrapMode: Text.WordWrap
            font.family: root.font
            font.pixelSize: 12
            Layout.fillWidth: true
          }

          Text {
            visible: NetworkService.connectionMessage.length > 0
            text: NetworkService.connectionMessage
            color: root.theme.accentGreen
            wrapMode: Text.WordWrap
            font.family: root.font
            font.pixelSize: 12
            Layout.fillWidth: true
          }

          Text {
            visible: NetworkService.connectionError.length > 0
            text: NetworkService.connectionError
            color: root.theme.accentRed
            wrapMode: Text.WordWrap
            font.family: root.font
            font.pixelSize: 12
            Layout.fillWidth: true
          }

          NetworkSection {
            visible: NetworkService.knownNetworks.length > 0
            theme: root.theme
            font: root.font
            title: qsTr("Saved networks")
            networks: NetworkService.knownNetworks
            Layout.fillWidth: true
            onNetworkActivated: network => root.activateNetwork(network)
          }

          NetworkSection {
            theme: root.theme
            font: root.font
            title: qsTr("Other networks")
            networks: NetworkService.otherNetworks
            collapsible: true
            emptyText: qsTr("No other networks found")
            Layout.fillWidth: true
            onNetworkActivated: network => root.activateNetwork(network)
          }
        }
      }

      Button {
        text: qsTr("Other settings")
        Layout.fillWidth: true
        onClicked: {
          root.closePopover();
          NetworkService.openSettings();
        }
      }
    }

    Rectangle {
      visible: root.passwordPromptOpen
      color: root.theme.bgOverlay
      radius: panel.radius

      anchors.fill: parent
      MouseArea {
        anchors.fill: parent
        onClicked: root.closePasswordPrompt()
      }

      Loader {
        id: passwordDialogLoader
        width: parent.width - 40
        height: 146
        active: root.passwordPromptOpen
        focus: true

        sourceComponent: Component {
          NetworkPasswordDialog {
            theme: root.theme
            font: root.font
            networkName: root.selectedNetwork?.name ?? ""
            onSubmitted: password => {
              if (NetworkService.connectNetwork(root.selectedNetwork, password)) root.closePasswordPrompt();
            }
            onCancelled: root.closePasswordPrompt()
          }
        }
        anchors.centerIn: parent
      }
    }
  }
  function closePopover() {
    closedByUser();
  }

  function activateNetwork(network) {
    if (NetworkService.passwordRequired(network)) {
      selectedNetwork = network;
      passwordPromptOpen = true;
    } else {
      NetworkService.connectNetwork(network);
    }
  }

  function closePasswordPrompt() {
    passwordPromptOpen = false;
    selectedNetwork = null;
  }

}

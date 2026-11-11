import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import qs.config

pragma ComponentBehavior: Bound

FocusScope {
  id: root

  required property Theme theme
  required property string font
  required property string networkName
  signal submitted(string password)
  signal cancelled()

  implicitHeight: 146

  Keys.onEscapePressed: event => {
    root.cancelled();
    event.accepted = true;
  }

  Component.onCompleted: password.forceActiveFocus()
  Rectangle {
    color: root.theme.bgSurface
    radius: 8
    anchors.fill: parent
  }

  ColumnLayout {
    spacing: 8

    anchors.fill: parent
    anchors.margins: 12
    Text {
      text: qsTr("Join %1").arg(root.networkName)
      color: root.theme.textPrimary
      font.family: root.font
      font.pixelSize: 13
      Layout.fillWidth: true
    }

    Text {
      text: qsTr("Password")
      color: root.theme.textSecondary
      font.family: root.font
      font.pixelSize: 11
      Layout.fillWidth: true
    }

    TextField {
      id: password
      echoMode: TextInput.Password
      placeholderText: qsTr("Password")
      color: root.theme.textPrimary
      placeholderTextColor: root.theme.textMuted
      selectionColor: root.theme.accentPrimary
      background: Rectangle {
        color: root.theme.bgBase
        radius: 5
        border.color: password.activeFocus ? root.theme.accentPrimary : root.theme.bgBorder
        border.width: 1
      }
      Layout.fillWidth: true
      Layout.preferredHeight: 30
      KeyNavigation.tab: cancelButton
      KeyNavigation.backtab: connectButton
      KeyNavigation.priority: KeyNavigation.BeforeItem
      Keys.onReturnPressed: event => {
        if (password.text.length > 0) root.submitted(password.text);
        event.accepted = true;
      }
      Keys.onEnterPressed: event => {
        if (password.text.length > 0) root.submitted(password.text);
        event.accepted = true;
      }
    }

    RowLayout {
      spacing: 8

      Layout.alignment: Qt.AlignRight
      Button {
        id: cancelButton
        text: qsTr("Cancel")
        KeyNavigation.tab: connectButton
        KeyNavigation.backtab: password
        KeyNavigation.priority: KeyNavigation.BeforeItem
        onClicked: root.cancelled()
      }
      Button {
        id: connectButton
        text: qsTr("Connect")
        enabled: password.text.length > 0
        KeyNavigation.tab: password
        KeyNavigation.backtab: cancelButton
        KeyNavigation.priority: KeyNavigation.BeforeItem
        onClicked: root.submitted(password.text)
      }
    }
  }
}

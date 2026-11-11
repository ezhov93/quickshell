import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.modules.Notifications.services

Rectangle {
    id: root
    required property Theme theme
    required property string font

    required property NotificationData modelData
    required property int index

    radius: 12
    color: root.theme.bgBase
    border.color: modelData.isCritical ? root.theme.urgencyCritical :
                  modelData.isLow      ? root.theme.urgencyLow      : root.theme.bgBorder
    border.width: 1
    clip: true
    Layout.fillWidth: true
    Layout.preferredHeight: cardContent.implicitHeight + 24

    Accessible.role: Accessible.StaticText
    Accessible.name: (modelData.isCritical ? "[Critical] " :
                     modelData.isLow      ? "[Low] "      : "") +
                     (modelData.appName || "Notification") + ": " + modelData.summary

    HoverHandler {
        id: cardHover
        onHoveredChanged: root.modelData.hovered = hovered
    }

    NumberAnimation on opacity {
        id: entryAnim
        from: 0; to: 1
        duration: 200
        easing.type: Easing.OutCubic
        running: false
    }
    Component.onCompleted: entryAnim.start()

    Rectangle {
        width: 3
        height: parent.height - 16
        radius: 2
        anchors {
            left: parent.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }
        color: root.modelData.isCritical ? root.theme.urgencyCritical :
               root.modelData.isLow      ? root.theme.urgencyLow      : root.theme.urgencyNormal
    }

    ColumnLayout {
        id: cardContent
        anchors {
            fill: parent
            leftMargin: 16
            rightMargin: 12
            topMargin: 12
            bottomMargin: 12
        }
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter

                IconImage {
                    anchors.centerIn: parent
                    source: Quickshell.iconPath(root.modelData.appIcon, true)
                    implicitSize: 16
                    visible: root.modelData.appIcon !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.modelData.appIcon === ""
                    text: {
                        const name = root.modelData.appName.toLowerCase();
                        if (root.modelData.isCritical) return "󰀦";
                        if (name.includes("discord"))  return "󰙯";
                        if (name.includes("firefox"))  return "󰈹";
                        if (name.includes("chrome"))   return "";
                        if (name.includes("telegram")) return "";
                        if (name.includes("spotify"))  return "󰓇";
                        if (name.includes("terminal") || name.includes("kitty") || name.includes("alacritty")) return "";
                        return "󰂚";
                    }
                    color: root.modelData.isCritical
                           ? root.theme.urgencyCritical : root.theme.urgencyNormal
                    font.pixelSize: 14
                    font.family: root.font
                }
            }

            Text {
                text: root.modelData.appName || "Notification"
                color: root.theme.textMuted
                font.pixelSize: 11
                font.family: root.font
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: closeHover.containsMouse ? root.theme.bgBorder : "transparent"
                Layout.alignment: Qt.AlignVCenter
                Accessible.role: Accessible.Button
                Accessible.name: "Dismiss notification"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: closeHover.containsMouse ? root.theme.accentRed : root.theme.textMuted
                    font.pixelSize: 12
                    font.family: root.font
                }

                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.modelData.dismiss()
                }
            }
        }

        Text {
            text: root.modelData.summary
            color: root.theme.textPrimary
            font {
                pixelSize: 13
                family: root.font
                bold: true
            }
            elide: Text.ElideRight
            Layout.fillWidth: true
            visible: text !== ""
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.modelData.body !== "" || root.modelData.image !== ""

            Text {
                text: root.modelData.body
                color: root.theme.textSecondary
                font.pixelSize: 12
                font.family: root.font
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
                textFormat: Text.PlainText
            }

            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                visible: root.modelData.image !== ""

                Image {
                    id: notificationImage
                    anchors.fill: parent
                    source: root.modelData.image
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 24
                    sourceSize.height: 24
                    asynchronous: true
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰋼"
                    color: root.theme.textMuted
                    font.family: root.font
                    font.pixelSize: 14
                    visible: notificationImage.status !== Image.Ready
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: root.modelData.actions.length > 0

            Repeater {
                model: root.modelData.actions

                Rectangle {
                    id: actionBtn
                    required property var modelData

                    Layout.preferredHeight: 26
                    Layout.preferredWidth: actionText.width + 16
                    radius: 6
                    color: actionHover.containsMouse ? root.theme.bgBorder : root.theme.bgSurface

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: actionBtn.modelData.text || ""

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: actionBtn.modelData.text || ""
                        color: root.theme.accentPrimary
                        font.pixelSize: 11
                        font.family: root.font
                    }

                    MouseArea {
                        id: actionHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.modelData.invokeAction(actionBtn.modelData.identifier)
                    }
                }
            }
        }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
            radius: 1
            color: root.theme.bgSurface
            Layout.topMargin: 2
            visible: !root.modelData.isCritical

            Rectangle {
                id: progressBar
                height: parent.height
                width: parent.width
                radius: 1
                color: root.modelData.isCritical
                       ? root.theme.urgencyCritical : root.theme.urgencyNormal
                opacity: 0.6

                SequentialAnimation {
                    running: !root.modelData.isCritical
                    PauseAnimation { duration: 50 }
                    NumberAnimation {
                        target: progressBar
                        property: "width"
                        to: 0
                        duration: root.modelData.expireTimeout > 0
                                  ? root.modelData.expireTimeout
                                  : root.modelData.defaultTimeout  // no * 1000: matches the timer — Quickshell passes raw D-Bus ms
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: 30
        z: -1
        onClicked: root.modelData.dismiss()
        cursorShape: Qt.PointingHandCursor
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Rectangle {
    id: notifCard
    required property var theme
    required property string font

    required property var modelData
    required property int index

    Layout.fillWidth: true
    Layout.preferredHeight: cardContent.implicitHeight + 24
    radius: 12
    color: notifCard.theme.bgBase
    border.color: modelData.isCritical ? notifCard.theme.urgencyCritical :
                  modelData.isLow      ? notifCard.theme.urgencyLow      : notifCard.theme.bgBorder
    border.width: 1
    clip: true

    Accessible.role: Accessible.StaticText
    Accessible.name: (modelData.isCritical ? "[Critical] " :
                     modelData.isLow      ? "[Low] "      : "") +
                     (modelData.appName || "Notification") + ": " + modelData.summary

    HoverHandler {
        id: cardHover
        onHoveredChanged: notifCard.modelData.hovered = hovered
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
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        color: notifCard.modelData.isCritical ? notifCard.theme.urgencyCritical :
               notifCard.modelData.isLow      ? notifCard.theme.urgencyLow      : notifCard.theme.urgencyNormal
    }

    ColumnLayout {
        id: cardContent
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12
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
                    source: Quickshell.iconPath(notifCard.modelData.appIcon, true)
                    implicitSize: 16
                    visible: notifCard.modelData.appIcon !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: notifCard.modelData.appIcon === ""
                    text: {
                        const name = notifCard.modelData.appName.toLowerCase();
                        if (notifCard.modelData.isCritical) return "󰀦";
                        if (name.includes("discord"))  return "󰙯";
                        if (name.includes("firefox"))  return "󰈹";
                        if (name.includes("chrome"))   return "";
                        if (name.includes("telegram")) return "";
                        if (name.includes("spotify"))  return "󰓇";
                        if (name.includes("terminal") || name.includes("kitty") || name.includes("alacritty")) return "";
                        return "󰂚";
                    }
                    color: notifCard.modelData.isCritical
                           ? notifCard.theme.urgencyCritical : notifCard.theme.urgencyNormal
                    font.pixelSize: 14
                    font.family: notifCard.font
                }
            }

            Text {
                text: notifCard.modelData.appName || "Notification"
                color: notifCard.theme.textMuted
                font.pixelSize: 11
                font.family: notifCard.font
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: closeHover.containsMouse ? notifCard.theme.bgBorder : "transparent"
                Layout.alignment: Qt.AlignVCenter
                Accessible.role: Accessible.Button
                Accessible.name: "Dismiss notification"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: closeHover.containsMouse ? notifCard.theme.accentRed : notifCard.theme.textMuted
                    font.pixelSize: 12
                    font.family: notifCard.font
                }

                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notifCard.modelData.dismiss()
                }
            }
        }

        Text {
            text: notifCard.modelData.summary
            color: notifCard.theme.textPrimary
            font.pixelSize: 13
            font.family: notifCard.font
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
            visible: text !== ""
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: notifCard.modelData.body !== "" || notifCard.modelData.image !== ""

            Text {
                text: notifCard.modelData.body
                color: notifCard.theme.textSecondary
                font.pixelSize: 12
                font.family: notifCard.font
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
                textFormat: Text.PlainText
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 4
                color: "transparent"
                clip: true
                visible: notifCard.modelData.image !== ""

                Image {
                    anchors.fill: parent
                    source: notifCard.modelData.image
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 24
                    sourceSize.height: 24
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: notifCard.modelData.actions.length > 0

            Repeater {
                model: notifCard.modelData.actions

                Rectangle {
                    id: actionBtn
                    required property var modelData

                    Layout.preferredHeight: 26
                    Layout.preferredWidth: actionText.width + 16
                    radius: 6
                    color: actionHover.containsMouse ? notifCard.theme.bgBorder : notifCard.theme.bgSurface

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: actionBtn.modelData.text || ""

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: actionBtn.modelData.text || ""
                        color: notifCard.theme.accentPrimary
                        font.pixelSize: 11
                        font.family: notifCard.font
                    }

                    MouseArea {
                        id: actionHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notifCard.modelData.invokeAction(actionBtn.modelData.identifier)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            radius: 1
            color: notifCard.theme.bgSurface
            Layout.topMargin: 2
            visible: !notifCard.modelData.isCritical

            Rectangle {
                id: progressBar
                height: parent.height
                width: parent.width
                radius: 1
                color: notifCard.modelData.isCritical
                       ? notifCard.theme.urgencyCritical : notifCard.theme.urgencyNormal
                opacity: 0.6

                SequentialAnimation {
                    running: !notifCard.modelData.isCritical
                    PauseAnimation { duration: 50 }
                    NumberAnimation {
                        target: progressBar
                        property: "width"
                        to: 0
                        duration: notifCard.modelData.expireTimeout > 0
                                  ? notifCard.modelData.expireTimeout
                                  : notifCard.modelData.defaultTimeout  // no * 1000: matches the timer — Quickshell passes raw D-Bus ms
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: 30
        z: -1
        onClicked: notifCard.modelData.dismiss()
        cursorShape: Qt.PointingHandCursor
    }
}

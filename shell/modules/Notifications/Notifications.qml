import qs.config
import qs.modules.Notifications.components
import qs.modules.Notifications.services
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Scope {
    id: root
    property var theme: Theme
    property string font: Config.fontFamily

    IpcHandler {
        target: "notifications"

        function dismiss_all(): void {
            NotificationService.dismissAll();
        }

        function dnd_toggle(): void {
            NotificationService.doNotDisturb = !NotificationService.doNotDisturb;
        }
    }

    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: notificationLoader
            required property var modelData
            active: NotificationService.notifications.length > 0

            PanelWindow {
                id: notifWindow
                screen: notificationLoader.modelData

                focusable: false
                color: "transparent"

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "quickshell-notifications"

                exclusionMode: ExclusionMode.Ignore
                anchors {
                    top: true
                    right: true
                }

                implicitWidth: 380
                implicitHeight: Math.max(1, notifColumn.implicitHeight + 20)

                ColumnLayout {
                    id: notifColumn
                    anchors {
                        top: parent.top
                        right: parent.right
                        topMargin: 10
                        rightMargin: 10
                    }
                    width: 360
                    spacing: 8

                    Repeater {
                        model: ScriptModel {
                            values: NotificationService.notifications
                            objectProp: "seqId"
                        }

                        NotificationCard {
                            theme: root.theme
                            font: root.font
                        }
                    }
                }
            }
        }
    }
}

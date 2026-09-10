import QtQuick
import Quickshell.Services.Notifications
import qs.config

QtObject {
    id: notificationData

    property Notification notification: null
    property bool closed: false

    property string seqId: ""
    property string notifId: ""

    readonly property string summary: notification?.summary || ""
    readonly property string body: notification?.body || ""
    readonly property string appIcon: notification?.appIcon || ""
    readonly property string appName: notification?.appName || ""
    readonly property string image: notification?.image || ""
    readonly property var actions: notification ? notification.actions.map(a => ({ identifier: a.identifier, text: a.text })) : []
    readonly property int urgency: notification?.urgency ?? NotificationUrgency.Normal
    readonly property bool isCritical: urgency === NotificationUrgency.Critical
    readonly property bool isLow: urgency === NotificationUrgency.Low
    readonly property real expireTimeout: notification && notification.expireTimeout > 0 ? notification.expireTimeout : defaultTimeout
    property bool hovered: false
    readonly property int defaultTimeout: Config.notificationDefaultTimeout

    readonly property Connections _conn: Connections {
        target: notificationData.notification
        function onClosed(): void {
            if (notificationData.closed) return;
            notificationData.closed = true;
            NotificationService._remove(notificationData);
            notificationData.destroy();
        }
    }

    readonly property Timer _timer: Timer {
        running: !notificationData.closed && !notificationData.hovered
                 && !notificationData.isCritical
        interval: notificationData.expireTimeout
        onTriggered: notificationData.dismiss()
    }

    Component.onCompleted: notifId = notification ? String(notification.id || "") : ""

    function dismiss(): void {
        if (closed) return;
        closed = true;
        NotificationService._remove(notificationData);
        if (notification) try { notification.dismiss(); } catch(e) {}
        destroy();
    }

    function invokeAction(identifier): void {
        if (!identifier || closed) return;
        closed = true;
        NotificationService._remove(notificationData);
        if (notification) {
            const action = notification.actions.find(function(a) {
                return a.identifier === identifier;
            });
            if (action) try { action.invoke(); } catch(e) {}
        }
        destroy();
    }
}

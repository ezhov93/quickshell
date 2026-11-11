import QtQuick
import qs.config

Item {
  id: root

  required property var  monitor
  required property int  index
  required property bool selected
  required property Theme theme
  required property string font

  property list<var> mirroredBy: []
  property real dragMinX: 0
  property real dragMinY: 0
  property real dragMaxX: 100000
  property real dragMaxY: 100000

  signal clicked(int idx)
  signal dragStarted()
  signal dragEnded(int idx, real canvasX, real canvasY)

  Rectangle {
    radius: 6
    color: root.selected
      ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.15)
      : root.theme.bgBase
    opacity: root.monitor.disabled ? 0.45 : 1.0

    anchors.fill: parent
    border.color: root.selected
                  ? root.theme.accentPrimary
                  : (root._isMirror && !root.monitor.disabled
                     ? root.theme.accentCyan
                     : root.theme.bgBorder)
    border.width: root.selected ? 2 : 1
    Text {
      id: nameText
      text: root.monitor.name
      color: root.selected ? root.theme.accentPrimary : root.theme.textPrimary
      elide: Text.ElideRight
      anchors {
        top: parent.top
        left: parent.left
        right: sourceBadge.visible ? sourceBadge.left : parent.right
        topMargin: 8
        leftMargin: 8
        rightMargin: sourceBadge.visible ? 4 : 8
      }
      font {
        pixelSize: Math.max(9, Math.min(13, root.width / 10))
        bold: true
        family: root.font
      }
    }

    Text {
      text: root.monitor.disabled
            ? "disabled"
            : (root._isMirror
               ? "↔ " + root.monitor.mirrorOf
               : root.monitor.selectedMode.replace("Hz", ""))
      color: (root._isMirror && !root.monitor.disabled)
             ? root.theme.accentCyan
             : root.theme.textSecondary
      horizontalAlignment: Text.AlignHCenter
      visible: root.width > 60
      anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: root._inStrip ? undefined : parent.verticalCenter
        bottom: root._inStrip ? parent.bottom : undefined
        bottomMargin: root._inStrip ? 6 : 0
      }
      font {
        pixelSize: Math.max(8, Math.min(11, root.width / 14))
        family: root.font
      }
    }

    Rectangle {
      id: sourceBadge
      height: 16
      width: badgeText.implicitWidth + 10
      radius: 4
      color: Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b, 0.18)
      visible: root.mirroredBy.length > 0 && root.width > 80

      border.color: root.theme.accentCyan
      border.width: 1
      anchors { top: parent.top; right: parent.right; topMargin: 6; rightMargin: 6 }
      Text {
        id: badgeText
        text: root.mirroredBy.length === 1
              ? "↔ " + root.mirroredBy[0]
              : "↔ " + root.mirroredBy.length
        color: root.theme.accentCyan
        anchors.centerIn: parent
        font { pixelSize: 9; family: root.font }
      }
    }

    Text {
      text: (["", "90°", "180°", "270°", "", "90°", "180°", "270°"])[root.monitor.transform] ?? ""
      color: root.theme.accentOrange
      visible: root.monitor.transform !== 0
      anchors { bottom: parent.bottom; right: parent.right; margins: 6 }
      font { pixelSize: 9; family: root.font }
    }
    // Rotation badge — bottom-right
  }

  MouseArea {
    id: dragArea
    cursorShape: root._inStrip ? Qt.PointingHandCursor : Qt.SizeAllCursor

    anchors.fill: parent
    onClicked: root.clicked(root.index)

    onPressed: {
      if (drag.target !== null) root.dragStarted();
    }
    onReleased: {
      if (drag.active) root.dragEnded(root.index, root.x, root.y);
    }
    drag {
      target: root._inStrip ? null : root
      axis: Drag.XAndYAxis
      minimumX: root.dragMinX
      minimumY: root.dragMinY
      maximumX: root.dragMaxX
      maximumY: root.dragMaxY
    }
  }
  // Use distinct param names (idx, not index) to avoid shadowing the required property
  // Drag boundary (canvas coordinates). Set by MonitorCanvas so tiles can't escape the canvas.
  readonly property bool _isMirror: monitor.mirrorOf !== ""
  readonly property bool _inStrip: monitor.disabled || _isMirror

}

import QtQuick
import qs.config
import qs.modules.MonitorManager.services

Item {
  id: root

  required property list<var> monitors
  required property int selectedIndex
  required property Theme theme
  required property string font

  property bool isDragging: false

  signal monitorSelected(int index)
  signal monitorMoved(int index, real newX, real newY)

  function _onCanvas(m) { return !m.disabled && m.mirrorOf === ""; }

  readonly property real _minX: {
    let min = Infinity;
    for (const m of monitors) {
      if (!_onCanvas(m)) continue;
      min = Math.min(min, m.x);
    }
    return isFinite(min) ? min : 0;
  }
  readonly property real _minY: {
    let min = Infinity;
    for (const m of monitors) {
      if (!_onCanvas(m)) continue;
      min = Math.min(min, m.y);
    }
    return isFinite(min) ? min : 0;
  }
  readonly property real _totalW: {
    let max = 1;
    for (const m of monitors) {
      if (!_onCanvas(m)) continue;
      max = Math.max(max, m.x + MonitorUtils.logicalW(m));
    }
    return Math.max(1, max - _minX);
  }
  readonly property real _totalH: {
    let max = 1;
    for (const m of monitors) {
      if (!_onCanvas(m)) continue;
      max = Math.max(max, m.y + MonitorUtils.logicalH(m));
    }
    return Math.max(1, max - _minY);
  }

  readonly property int _stripCount: {
    let n = 0;
    for (const m of monitors) { if (!_onCanvas(m)) n++; }
    return n;
  }
  readonly property var _overlapByName: {
    const result = {};
    for (let i = 0; i < monitors.length; i++) {
      const first = monitors[i];
      if (!_onCanvas(first)) continue;
      const firstWidth = MonitorUtils.logicalW(first);
      const firstHeight = MonitorUtils.logicalH(first);
      for (let j = i + 1; j < monitors.length; j++) {
        const second = monitors[j];
        if (!_onCanvas(second)) continue;
        if (MonitorUtils.overlapsAABB(
              first.x, first.y, firstWidth, firstHeight,
              second.x, second.y, MonitorUtils.logicalW(second), MonitorUtils.logicalH(second))) {
          result[first.name] = true;
          result[second.name] = true;
        }
      }
    }
    return result;
  }

  Rectangle {
    color: root.theme.bgSurface
    radius: 8
    anchors.fill: parent
  }

  Canvas {
    id: dotTile
    property color dotColor: root.theme.textMuted
    property string dataUrl: ""

    width: 24
    height: 24
    visible: false

    onAvailableChanged: if (available) requestPaint()
    onDotColorChanged:  if (available) requestPaint()

    onPaint: {
      const ctx = getContext("2d");
      ctx.clearRect(0, 0, width, height);
      ctx.fillStyle = `rgba(${Math.round(dotColor.r * 255)}, ${Math.round(dotColor.g * 255)}, ${Math.round(dotColor.b * 255)}, 0.3)`;
      ctx.beginPath();
      ctx.arc(width / 2, height / 2, 1.5, 0, Math.PI * 2);
      ctx.fill();
      dataUrl = toDataURL();
    }
    // https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html#property-change-signal-handlers
  }

  Image {
    source: dotTile.dataUrl
    fillMode: Image.Tile
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    smooth: false
    visible: source !== ""
    sourceSize.width: 24
    sourceSize.height: 24
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      bottomMargin: root._stripH
    }
  }

  Item {
    anchors.fill: parent
    Rectangle {
      width: parent.width; height: 1
      color: root.theme.bgBorder
      opacity: 0.4
      anchors.centerIn: parent
    }
    Rectangle {
      width: 1; height: parent.height
      color: root.theme.bgBorder
      opacity: 0.4
      anchors.centerIn: parent
    }
  }

  Rectangle {
    visible: root._stripH > 0
    height: root._stripH
    radius: 8
    color: Qt.rgba(0, 0, 0, 0.15)

    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
    }
    Text {
      text: "Not in arrangement"
      color: root.theme.textMuted
      anchors { top: parent.top; left: parent.left; topMargin: 6; leftMargin: 10 }
      font { pixelSize: 10; family: root.font }
    }
  }

  Repeater {
    id: enabledTiles
    model: root.monitors

    delegate: MonitorTile {
      id: enabledTile

      required property var modelData

      monitor:    modelData
      selected:   root.selectedIndex === index
      theme:      root.theme
      font:       root.font
      mirroredBy: root._mirroredBy(modelData.name)

      visible: root._onCanvas(modelData)
      x: root.originX + modelData.x * root.viewScale
      y: root.originY + modelData.y * root.viewScale
      width:  MonitorUtils.logicalW(modelData) * root.viewScale
      height: MonitorUtils.logicalH(modelData) * root.viewScale

      dragMinX: 0
      dragMinY: 0
      dragMaxX: root.width  - width
      dragMaxY: root.height - root._stripH - height

      onClicked: root.monitorSelected(index)
      onDragStarted: root.isDragging = true
      onDragEnded: (idx, cx, cy) => {
        root.isDragging = false;
        root.snapAndCommit(idx, cx, cy);
      }
      Rectangle {
        color: "transparent"
        radius: 6
        visible: root._overlapByName[modelData.name] === true
        z: 2
        anchors.fill: parent
        border.color: root.theme.accentOrange
        border.width: 2
      }

      // Clamp drag so tiles cannot leave the root area
      // Orange border warns the user that two independent monitors are misaligned — a gap
      // or overlap that Hyprland will reject or mis-render.  Only root-placed monitors
      // are considered; disabled and mirroring outputs are excluded by definition.
    }
  }

  Repeater {
    id: stripTiles
    model: {
      const mirrors  = [];
      const disabled = [];
      for (let i = 0; i < root.monitors.length; i++) {
        const m = root.monitors[i];
        if (m.disabled)            disabled.push({ monitor: m, origIndex: i });
        else if (m.mirrorOf !== "") mirrors.push({ monitor: m, origIndex: i });
      }
      const all = mirrors.concat(disabled);
      return all.map((e, col) => Object.assign({}, e, { col: col }));
    }

    delegate: MonitorTile {
      required property var modelData

      monitor:  modelData.monitor
      index:    modelData.origIndex
      selected: root.selectedIndex === modelData.origIndex
      theme:    root.theme
      font:     root.font

      x: 10 + modelData.col * 128   // left-to-right, 120px tile + 8px gap
      y: root.height - root._stripH + 26   // 20px label row + 6px gap
      width: 120
      height: 52

      onClicked: idx => root.monitorSelected(idx)
      onDragStarted: {}
      onDragEnded: (idx, cx, cy) => {}
    }
  }

  function _mirroredBy(name) {
    const r = [];
    for (const m of monitors) {
      if (!m.disabled && m.mirrorOf === name) r.push(m.name);
    }
    return r;
  }

  function snapAndCommit(index, rawCanvasX, rawCanvasY) {
    let lx = (rawCanvasX - originX) / viewScale;
    let ly = (rawCanvasY - originY) / viewScale;

    const d  = monitors[index];
    const dW = MonitorUtils.logicalW(d);
    const dH = MonitorUtils.logicalH(d);
    const T  = 20;

    let sx = false, sy = false;

    // Snap to root origin and adjacent monitor edges.
    if (!sx && Math.abs(lx) < T)      { lx = 0;   sx = true; }
    if (!sy && Math.abs(ly) < T)      { ly = 0;   sy = true; }

    for (let i = 0; i < monitors.length; i++) {
      if (i === index || !_onCanvas(monitors[i])) continue;
      const m  = monitors[i];
      const mW = MonitorUtils.logicalW(m);
      const mH = MonitorUtils.logicalH(m);

      if (!sx) {
        if      (Math.abs(lx      - (m.x + mW)) < T) { lx = m.x + mW; sx = true; }
        else if (Math.abs(lx + dW - m.x)         < T) { lx = m.x - dW; sx = true; }
        else if (Math.abs(lx      - m.x)         < T) { lx = m.x;      sx = true; }
      }
      if (!sy) {
        if      (Math.abs(ly      - (m.y + mH)) < T) { ly = m.y + mH; sy = true; }
        else if (Math.abs(ly + dH - m.y)        < T) { ly = m.y - dH; sy = true; }
        else if (Math.abs(ly      - m.y)        < T) { ly = m.y;      sy = true; }
      }
      if (sx && sy) break;
    }

    for (let iter = 0; iter < monitors.length + 2; iter++) {
      let anyOverlap = false;
      for (let i = 0; i < monitors.length; i++) {
        if (i === index || !_onCanvas(monitors[i])) continue;
        const o  = monitors[i];
        const oW = MonitorUtils.logicalW(o);
        const oH = MonitorUtils.logicalH(o);
        if (!MonitorUtils.overlapsAABB(lx, ly, dW, dH, o.x, o.y, oW, oH)) continue;

        const relX = (lx + dW / 2) - (o.x + oW / 2);
        const relY = (ly + dH / 2) - (o.y + oH / 2);
        if (Math.abs(relX) >= Math.abs(relY)) {
          if (relX >= 0) {
            lx = o.x + oW;                              // place to the right of o
          } else {
            const target = o.x - dW;
            lx = target >= 0 ? target : o.x + oW;      // prefer left; fall back right
          }
        } else {
          if (relY >= 0) {
            ly = o.y + oH;                              // place below o
          } else {
            const target = o.y - dH;
            ly = target >= 0 ? target : o.y + oH;      // prefer above; fall back below
          }
          // Horizontal resolution — snap to o's right or left edge.
          // Vertical resolution — snap to o's bottom or top edge.
        }

        anyOverlap = true;
        break; // restart scan so the new position is checked against all monitors
      }
      if (!anyOverlap) break;
    }

    // Snap to root origin
    // Snap to adjacent monitor edges — only against root-placed monitors;
    // mirrors share coordinates with their source so snapping against them
    // would be redundant noise.
    // Auto-snap to the nearest edge of any overlapping monitor.
    //
    //    Uses the same quadrant logic as placeSelected() in the old MonitorManager:
    //    compare the dragged tile's center to the other tile's center to decide
    //    left / right / above / below, then place flush against that edge.
    //    If the preferred direction would result in a negative coordinate (invalid
    //    in Hyprland), fall back to the opposite direction.
    //
    //    Each iteration resolves one overlap then restarts the scan (a snap may
    //    create a new overlap with a third monitor).  Bounded by
    //    (monitors.length + 2) to guarantee termination.
    // Clamp to non-negative coordinates (root bounding box assumes origin at 0,0).
    lx = Math.max(0, lx);
    ly = Math.max(0, ly);

    root.monitorMoved(index, Math.round(lx), Math.round(ly));
  }
  // Bottom strip holds every monitor that isn't part of the arrangement
  readonly property real _stripH: _stripCount > 0 ? 86 : 0

  readonly property real viewScale:
    Math.min((width - 80) / Math.max(_totalW, 1),
             (height - 80 - _stripH) / Math.max(_totalH, 1))

  readonly property real originX: (width - _totalW * viewScale) / 2 - _minX * viewScale
  readonly property real originY: (_stripH === 0
    ? (height - _totalH * viewScale) / 2
    : (height - _stripH - _totalH * viewScale) / 2) - _minY * viewScale

  // Canvas background
  // Dot grid background — painted once into a 24×24 tile, then GPU-tiled across the
  // root via Image.Tile.  Resizes don't re-run any JS; only theme changes repaint
  // the single tile.
  // Center crosshair
}

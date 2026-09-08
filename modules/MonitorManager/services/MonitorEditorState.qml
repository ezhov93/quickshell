import Quickshell
import QtQuick

Scope {
  id: root
  property var service: MonitorService
  property var  editState:       []
  property int  selectedIndex:   -1
  property bool isOpen:          false
  property bool isApplying:      false
  property string applyError:    ""
  property bool hotplugDetected: false
  property bool persistWarning:  false
  property var  _openSnapshot:   []
  property bool _isInitialLoad:  false

  function openEditor() {
    isOpen          = true;
    selectedIndex   = -1;
    applyError      = "";
    hotplugDetected = false;
    persistWarning  = !root.service.persistenceAvailable;
    editState       = [];
    _openSnapshot   = [];
    _isInitialLoad  = true;
    root.service.refresh();
  }

  function initEditState() {
    const raw = root.service.monitors.map(m => Object.assign({}, m));

    // Auto-place newly appeared monitors that land at (0,0) overlapping others
    const enabled    = raw.filter(m => !m.disabled);
    const rightEdge  = enabled.reduce((max, m) => {
      const atOrigin = m.x === 0 && m.y === 0;
      return atOrigin ? max : Math.max(max, m.x + MonitorUtils.logicalW(m));
    }, 0);

    for (const m of raw) {
      if (m.disabled || !(m.x === 0 && m.y === 0)) continue;
      const others   = enabled.filter(o => o.name !== m.name);
      const overlaps = others.some(o =>
        MonitorUtils.overlapsAABB(m.x, m.y, MonitorUtils.logicalW(m), MonitorUtils.logicalH(m),
                                  o.x, o.y, MonitorUtils.logicalW(o), MonitorUtils.logicalH(o))
      );
      if (overlaps) m.x = rightEdge;
    }

    editState      = raw;
    _openSnapshot  = root.service.monitors.map(m => Object.assign({}, m));
    _isInitialLoad = false;
  }

  // True when any two enabled, non-mirroring monitors overlap
  readonly property bool hasOverlap: {
    const enabled = editState.filter(m => !m.disabled && m.mirrorOf === "");
    for (let i = 0; i < enabled.length; i++) {
      for (let j = i + 1; j < enabled.length; j++) {
        const a = enabled[i], b = enabled[j];
        if (MonitorUtils.overlapsAABB(
              a.x, a.y, MonitorUtils.logicalW(a), MonitorUtils.logicalH(a),
              b.x, b.y, MonitorUtils.logicalW(b), MonitorUtils.logicalH(b)))
          return true;
      }
    }
    return false;
  }

  function applyChanges() {
    const enabledCount = editState.filter(m => !m.disabled).length;
    if (enabledCount === 0) {
      applyError = "At least one monitor must remain enabled.";
      return;
    }
    if (root.hasOverlap) {
      applyError = "Monitors are overlapping — drag them apart before applying.";
      return;
    }
    applyError = "";
    isApplying = true;
    // persistToFile is called in onApplyDone success path — not here,
    // so we never write an invalid config to disk
    root.service.apply(editState);
  }

  function cancelChanges() {
    if (!isApplying) isOpen = false;
  }

  function _hasExternalChange() {
    const live = root.service.monitors;
    if (live.length !== _openSnapshot.length) return true;
    for (const snap of _openSnapshot) {
      const l = live.find(m => m.name === snap.name);
      if (!l) return true;
      if (l.selectedMode !== snap.selectedMode) return true;
      if (l.disabled      !== snap.disabled)    return true;
      if (l.x             !== snap.x)           return true;
      if (l.y             !== snap.y)           return true;
      if (l.scale         !== snap.scale)       return true;
      if (l.transform     !== snap.transform)   return true;
    }
    return false;
  }

  // editState mutation helpers — all guarded against out-of-bounds selectedIndex
  function onModeSelected(mode) {
    if (selectedIndex < 0 || selectedIndex >= editState.length) return;
    const parsed = MonitorUtils.parseMode(mode);
    if (!parsed) return;
    updateSelected({
      selectedMode: mode,
      width:        parsed.w,
      height:       parsed.h,
    });
  }

  function onScaleChanged(scale) {
    updateSelected({ scale: scale });
  }

  function onTransformChanged(t) {
    updateSelected({ transform: t });
  }

  function onEnabledChanged(enabled) {
    if (selectedIndex < 0 || selectedIndex >= editState.length) return;
    const willBeDisabled = !enabled;
    if (willBeDisabled) {
      const currentlyEnabled = editState.filter(m => !m.disabled).length;
      if (currentlyEnabled <= 1) {
        applyError = "Cannot disable the only active monitor.";
        return;
      }
    }
    updateSelected({ disabled: willBeDisabled });
  }

  function onMirrorChanged(mirrorName) {
    if (selectedIndex < 0 || selectedIndex >= editState.length) return;
    let patch = { mirrorOf: mirrorName };
    if (mirrorName !== "") {
      const src = editState.find(m => m.name === mirrorName);
      if (src) { patch.x = src.x; patch.y = src.y; }
    }
    updateSelected(patch);
  }

  Connections {
    target: root.service

    function onApplyDone(hasErrors, errorText) {
      root.isApplying = false;
      if (hasErrors) {
        root.applyError = errorText;
      } else {
        // Only persist on confirmed success — never write an invalid config
        root.service.persistToFile(root.editState);
        root.initEditState();
        root.isOpen = false;
      }
    }

    function onMonitorsLoaded() {
      if (root.service._pendingVerify) return;
      if (!root.isOpen) return;

      if (root._isInitialLoad) {
        root.initEditState();
      } else {
        if (root._hasExternalChange()) {
          root.hotplugDetected = true;
          root._openSnapshot = root.service.monitors.map(m => Object.assign({}, m));
        }
      }
    }
  }

  function updateMonitor(index, patch) {
    if (index < 0 || index >= editState.length) return;
    const copy = editState.slice();
    copy[index] = Object.assign({}, editState[index], patch);
    editState = copy;
  }

  function updateSelected(patch) {
    updateMonitor(selectedIndex, patch);
  }
}

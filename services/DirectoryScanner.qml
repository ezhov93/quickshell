import QtQuick
import Qt.labs.folderlistmodel

QtObject {
  id: root
  property bool running: false
  property var queue: []
  property var entries: []
  property var reader: null
  signal finished(var entries)

  // A bounded breadth-first scan; each model is released after one directory.
  function scan(paths, maxDepth = 1) {
    if (running) return;
    entries = [];
    queue = paths.map(path => ({ path: path, depth: maxDepth }));
    running = true;
    next();
  }

  function next() {
    if (queue.length === 0) {
      running = false;
      finished(entries);
      return;
    }
    const task = queue.shift();
    reader = readerComponent.createObject(root, { directory: task.path, depth: task.depth });
    timeout.restart();
  }

  function collect(model) {
    if (!model || model !== reader || model.collected) return;
    model.collected = true;
    timeout.stop();
    for (let i = 0; i < model.count; ++i) {
      const path = model.get(i, "filePath");
      const isDir = model.get(i, "fileIsDir");
      entries.push({ path: path, name: model.get(i, "fileName"), isDir: isDir });
      if (isDir && model.depth > 1) queue.push({ path: path, depth: model.depth - 1 });
    }
    release();
  }

  function release() {
    if (reader) reader.destroy();
    reader = null;
    Qt.callLater(next);
  }

  readonly property Timer timeout: Timer {
    interval: 2000
    onTriggered: root.release()
  }

  readonly property Component readerComponent: Component {
    FolderListModel {
      required property string directory
      required property int depth
      property bool collected: false
      folder: "file://" + directory.split("/").map(encodeURIComponent).join("/")
      showDotAndDotDot: false
      showHidden: true
      sortField: FolderListModel.Name
      onStatusChanged: if (status === FolderListModel.Ready) Qt.callLater(root.collect, this)
      Component.onCompleted: if (status === FolderListModel.Ready) Qt.callLater(root.collect, this)
    }
  }
}

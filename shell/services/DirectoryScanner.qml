import QtQuick
import Qt.labs.folderlistmodel

QtObject {
  id: root
  property bool running: false
  property list<var> queue: []
  property list<var> entries: []
  property FolderListModel reader: null
  signal finished(var entries)

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
  function scan(paths, maxDepth = 1) {
    queue = paths.map(path => ({ path: path, depth: maxDepth }));
    if (running) return;
    entries = [];
    running = true;
    next();
  }

  function next() {
    if (queue.length === 0) {
      running = false;
      finished(entries);
      return;
    }
    const task = queue[0];
    queue = queue.slice(1);
    reader = readerComponent.createObject(root, { directory: task.path, depth: task.depth });
    timeout.restart();
  }

  function collect(model) {
    if (!model || model !== reader || model.collected) return;
    model.collected = true;
    timeout.stop();
    const foundEntries = [];
    const foundDirectories = [];
    for (let i = 0; i < model.count; ++i) {
      const path = model.get(i, "filePath");
      const isDir = model.get(i, "fileIsDir");
      foundEntries.push({ path: path, name: model.get(i, "fileName"), isDir: isDir });
      if (isDir && model.depth > 1) foundDirectories.push({ path: path, depth: model.depth - 1 });
    }
    entries = entries.concat(foundEntries);
    queue = queue.concat(foundDirectories);
    release();
  }

  function release() {
    if (reader) reader.destroy();
    reader = null;
    Qt.callLater(next);
  }

  // A bounded breadth-first scan; each model is released after one directory.
}

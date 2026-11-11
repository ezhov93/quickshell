import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: root
  property bool busy: false
  signal completed(bool success, string error)

  Component {
    id: writerComponent
    FileView {
      id: writer
      required property string destination
      property bool done: false
      path: destination
      preload: false
      blockLoading: false
      blockWrites: false
      printErrors: false
      atomicWrites: true
      onSaved: {
        if (done) return;
        done = true;
        Qt.callLater(root.finish, writer, "");
      }
      onSaveFailed: error => {
        if (done) return;
        done = true;
        Qt.callLater(root.finish, writer, FileViewError.toString(error));
      }
    }
  }
  function write(path, content) {
    if (!path || !content) { completed(false, "Empty file path or content"); return; }
    if (busy) return;
    const writer = writerComponent.createObject(root, { destination: path });
    busy = true;
    // A fresh FileView also writes unchanged content. Reusing a reader can skip
    // setText() without emitting saved(), or retain data from a previous path.
    Qt.callLater(() => writer.setText(content));
  }
  function finish(writer, error) {
    writer.destroy();
    busy = false;
    completed(error === "", error);
  }
}

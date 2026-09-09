pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Singleton {
  id: root
  property string socketPath: Hyprland.requestSocketPath
  property var queue: []
  property var current: null

  function request(command, callback) {
    queue.push({ command: command, callback: callback });
    next();
  }
  function next() {
    if (current || queue.length === 0) return;
    const task = queue.shift();
    current = jobComponent.createObject(root, { command: task.command, callback: task.callback });
    current.start();
  }

  Component {
    id: jobComponent
    Scope {
      id: job
      required property string command
      required property var callback
      property bool finished: false
      property bool sent: false

      function start() {
        if (!root.socketPath) { finish("", "Hyprland socket is unavailable"); return; }
        timeout.start();
        socket.connected = true;
      }
      function finish(reply, error) {
        if (finished) return;
        finished = true;
        timeout.stop();
        socket.connected = false;
        try { callback(reply, error); }
        finally {
          root.current = null;
          job.destroy();
          Qt.callLater(root.next);
        }
      }
      Socket {
        id: socket
        path: root.socketPath
        parser: StdioCollector { id: response; waitForEnd: false }
        onConnectionStateChanged: {
          if (connected) {
            job.sent = true;
            write(job.command);
            flush();
          } else if (job.sent && !job.finished) {
            job.finish(response.text, response.text === "" ? "Empty Hyprland response" : "");
          }
        }
        onError: error => {
          // PeerClosedError is the normal end of a Hyprland response.
          if (error !== 1) job.finish("", "Hyprland socket error: " + error);
        }
      }
      Timer {
        id: timeout
        interval: 3000
        onTriggered: job.finish("", "Hyprland request timed out")
      }
    }
  }
}

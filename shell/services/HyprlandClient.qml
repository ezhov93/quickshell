pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config

Singleton {
  id: root
  property string socketPath: Hyprland.requestSocketPath
  property list<var> queue: []
  property var current: null

  Component {
    id: jobComponent
    Scope {
      id: job
      required property string command
      required property var callback
      property bool finished: false
      property bool sent: false

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
        interval: Config.monitorApplyVerifyTimeout
        onTriggered: job.finish("", "Hyprland request timed out")
      }
      function start() {
        if (!root.socketPath) { finish("", "Hyprland socket is unavailable"); return; }
        timeout.start();
        socket.connected = true;
      }
      function finish(reply, error) {
        try { callback(reply, error); }
        finally {
          root.current = null;
          job.destroy();
          Qt.callLater(root.next);
        }
        if (finished) return;
        finished = true;
        timeout.stop();
        socket.connected = false;
      }
    }
  }
  function request(command, callback) {
    queue = queue.concat([{ command: command, callback: callback }]);
    next();
  }
  function next() {
    if (current || queue.length === 0) return;
    const task = queue[0];
    queue = queue.slice(1);
    current = jobComponent.createObject(root, { command: task.command, callback: task.callback });
    current.start();
  }

}

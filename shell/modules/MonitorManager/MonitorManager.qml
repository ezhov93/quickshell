import qs.config
import qs.modules.MonitorManager.components
import qs.modules.MonitorManager.services
import Quickshell
import Quickshell.Io

Scope {
  id: root

  property var  theme: Theme
  property string font: Config.fontFamily

  MonitorEditorState { id: editorState }

  IpcHandler {
    target: "monitors"
    function toggle(): void {
      if (editorState.isOpen) editorState.cancelChanges();
      else editorState.openEditor();
    }
    function refresh(): void { MonitorService.refresh(); }
  }

  LazyLoader {
    active: editorState.isOpen
    MonitorWindow {
      theme: root.theme
      font: root.font
      editor: editorState
    }
  }
}

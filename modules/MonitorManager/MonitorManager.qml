import "components"
import "services"
import"../../themes" as Themes
import Quickshell
import Quickshell.Io

Scope {
  id: root

  property var  theme: Themes.DefaultTheme
  property string font: "Hack Nerd Font"

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

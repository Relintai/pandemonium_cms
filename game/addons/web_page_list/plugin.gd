tool
extends EditorPlugin

var web_pages_editor : Control = null

func _enter_tree():
	var wbes : PackedScene = ResourceLoader.load("res://addons/web_page_list/editor/WebPageListEditor.tscn")
	web_pages_editor = wbes.instance()
	web_pages_editor.undo_redo = get_undo_redo()
	
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		wne.add_main_screen_tab(web_pages_editor)

func _exit_tree():
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		wne.remove_main_screen_tab(web_pages_editor)
	
func get_plugin_name() -> String:
	return "WebPageListEditorPlugin"

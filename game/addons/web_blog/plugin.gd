tool
extends EditorPlugin

var web_blog_editor : Control = null

func _enter_tree():
	var wbes : PackedScene = ResourceLoader.load("res://addons/web_blog/editor/WebBlogEditor.tscn")
	web_blog_editor = wbes.instance()
	
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		wne.add_main_screen_tab(web_blog_editor)

func _exit_tree():
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		wne.remove_main_screen_tab(web_blog_editor)
	
func get_plugin_name() -> String:
	return "WebBlogEditorPlugin"

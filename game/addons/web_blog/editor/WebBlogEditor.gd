tool
extends PanelContainer

var _wne_tool_bar_button : Button = null
var _edited_blog : WebBlog = null
var undo_redo : UndoRedo = null

func _enter_tree():
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		_wne_tool_bar_button = Button.new()
		_wne_tool_bar_button.set_text("Blog Editor")
		_wne_tool_bar_button.set_tooltip("HTML preview")
		_wne_tool_bar_button.set_toggle_mode(true)
		_wne_tool_bar_button.set_pressed(false)
		_wne_tool_bar_button.set_button_group(wne.get_main_button_group())
		_wne_tool_bar_button.set_keep_pressed_outside(true)
		wne.add_control_to_tool_bar(_wne_tool_bar_button)
		_wne_tool_bar_button.connect("toggled", self, "_on_blog_editor_button_toggled")
		wne.connect("edited_node_changed", self, "_edited_node_changed")
	
func _exit_tree():
	if _wne_tool_bar_button:
		_wne_tool_bar_button.queue_free()
		_wne_tool_bar_button = null
		
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		wne.disconnect("edited_node_changed", self, "_edited_node_changed")

func _on_blog_editor_button_toggled(on):
	if on:
		var wne : Control = Engine.get_global("WebNodeEditor")
		if wne:
			wne.switch_to_main_screen_tab(self)
			_wne_tool_bar_button.set_pressed_no_signal(true)
	
func _edited_node_changed(web_node : WebNode):
	_edited_blog = web_node
	
	if !_wne_tool_bar_button:
		return
		
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		if web_node is WebBlog:
			_wne_tool_bar_button.show()
			_wne_tool_bar_button.pressed = true
			#wne.switch_to_main_screen_tab(self)
		else:
			_wne_tool_bar_button.hide()
			#add method to switch off to the prev screen
			#wne.switch_to_main_screen_tab(self)

func _on_new_post_requested():
	if !_edited_blog:
		return
		
	var post : WebBlogPost = WebBlogPost.new()
	_edited_blog.add_post(post)
	
	var post_editor_scene : PackedScene = ResourceLoader.load("res://addons/web_blog/editor/PostEditor.tscn", "PackedScene")
	var nps : Control = post_editor_scene.instance()
	nps.undo_redo = undo_redo
	nps.set_post(post)
	get_node("./Tabs").add_child(nps)
	
	# Hack for now. Todo add support for this into UndoRedo without hacks
	undo_redo.create_action("Created WebBlog Post")
	undo_redo.add_do_method(_edited_blog, "null_method")
	undo_redo.add_undo_method(_edited_blog, "null_method")
	undo_redo.commit_action()


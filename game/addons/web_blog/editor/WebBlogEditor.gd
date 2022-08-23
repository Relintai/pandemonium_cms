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
		
	get_node("Tabs/Posts").undo_redo = undo_redo
	
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
	if !_wne_tool_bar_button:
		return
	
	var wne : Control = Engine.get_global("WebNodeEditor")
	if wne:
		if web_node is WebBlog:
			_edited_blog = web_node
			get_node("Tabs/Posts").set_web_blog(_edited_blog)
			_wne_tool_bar_button.show()
			_wne_tool_bar_button.pressed = true
			#wne.switch_to_main_screen_tab(self)
		else:
			_wne_tool_bar_button.hide()
			#_edited_blog = null
			#add method to switch off to the prev screen
			#wne.switch_to_main_screen_tab(self)

func _on_new_post_requested():
	if !_edited_blog:
		return
		
	var _tabs : TabContainer = get_node("./Tabs")
		
	var post : WebBlogPost = WebBlogPost.new()
	_edited_blog.add_post(post)
	
	var post_editor_scene : PackedScene = ResourceLoader.load("res://addons/web_blog/editor/PostEditor.tscn", "PackedScene")
	var nps : Control = post_editor_scene.instance()
	nps.undo_redo = undo_redo
	nps.set_post(post)
	_tabs.add_child(nps)
	_tabs.current_tab = _tabs.get_child_count() - 1

func _on_blog_post_edit_requested(post : WebBlogPost) -> void:
	if !_edited_blog:
		return
		
	var _tabs : TabContainer = get_node("./Tabs")
		
	var post_editor_scene : PackedScene = ResourceLoader.load("res://addons/web_blog/editor/PostEditor.tscn", "PackedScene")
	var nps : Control = post_editor_scene.instance()
	nps.undo_redo = undo_redo
	nps.set_post(post)
	_tabs.add_child(nps)
	_tabs.current_tab = _tabs.get_child_count() - 1

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		var _posts : Control = get_node("Tabs/Posts")
		_posts.connect("new_post_request", self, "_on_new_post_requested")
		_posts.connect("blog_post_edit_requested", self, "_on_blog_post_edit_requested")

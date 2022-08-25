tool
extends VBoxContainer

var _wne_tool_bar_button : Button = null

var _post : WebPage = null
var undo_redo : UndoRedo = null

func set_post(post : WebPage):
	_post = post
	get_node("HBoxContainer/PostNameLE").text = post.name
	name = post.name
	
func _on_PostNameLE_text_entered(new_text : String):
	var le : LineEdit = get_node("HBoxContainer/PostNameLE")
	
	undo_redo.create_action("Post name changed.")
	undo_redo.add_do_property(_post, "name", new_text)
	undo_redo.add_undo_property(_post, "name", _post.name)
	undo_redo.add_do_property(le, "text", new_text)
	undo_redo.add_undo_property(le, "text", _post.name)
	undo_redo.add_do_property(self, "name", new_text)
	undo_redo.add_undo_property(self, "name", _post.name)
	undo_redo.commit_action()

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		var le : LineEdit = get_node("HBoxContainer/PostNameLE")
		le.connect("text_entered", self, "_on_PostNameLE_text_entered")
	elif what == NOTIFICATION_ENTER_TREE:
		var wne : Control = Engine.get_global("WebNodeEditor")
		if wne:
			_wne_tool_bar_button = Button.new()
			_wne_tool_bar_button.set_text("Web Page Editor")
			_wne_tool_bar_button.set_toggle_mode(true)
			_wne_tool_bar_button.set_pressed(false)
			_wne_tool_bar_button.set_button_group(wne.get_main_button_group())
			_wne_tool_bar_button.set_keep_pressed_outside(true)
			wne.add_control_to_tool_bar(_wne_tool_bar_button)
			_wne_tool_bar_button.connect("toggled", self, "_on_blog_editor_button_toggled")
			wne.connect("edited_node_changed", self, "_edited_node_changed")
	elif what == NOTIFICATION_EXIT_TREE:
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
		if web_node is WebPage:
			_post = web_node
			_wne_tool_bar_button.show()
			_wne_tool_bar_button.pressed = true
			#wne.switch_to_main_screen_tab(self)
		else:
			_wne_tool_bar_button.hide()
			#_post = null
			#add method to switch off to the prev screen
			#wne.switch_to_main_screen_tab(self)


tool
extends Control

var _wne_tool_bar_button : Button = null

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

func _on_blog_editor_button_toggled(on):
	if on:
		var wne : Control = Engine.get_global("WebNodeEditor")
		if wne:
			wne.switch_to_main_screen_tab(self)
			_wne_tool_bar_button.set_pressed_no_signal(true)
	
func _edited_node_changed(web_node : WebNode):
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


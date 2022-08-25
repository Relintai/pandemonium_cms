tool
extends PanelContainer

var PageEditor : PackedScene = null

var _wne_tool_bar_button : Button = null

var _page : WebPage = null
var undo_redo : UndoRedo = null

var _entry_name_line_edit : LineEdit = null
var _uri_segment_line_edit : LineEdit = null
var _add_entry_popup : AcceptDialog = null

func set_page(page : WebPage):
	_page = page
	_entry_name_line_edit.text = page.name
	_uri_segment_line_edit.text = page.uri_segment

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_entry_name_line_edit = get_node("MC/Name/EntryNameLineEdit")
		_entry_name_line_edit.connect("text_entered", self, "_on_entry_name_line_edit_text_entered")
		
		_uri_segment_line_edit = get_node("MC/URISegment/URISegmentLE")
		_uri_segment_line_edit.connect("text_entered", self, "_on_uri_segment_line_edit_text_entered")
		
		_add_entry_popup = get_node("Popups/AddEntryPopup")
		_add_entry_popup.connect("on_entry_class_selected", self, "_on_add_entry_class_selected")
		
		PageEditor = ResourceLoader.load("res://addons/web_pages/editor/PageEditor.tscn", "PackedScene") as PackedScene
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
	
func _on_entry_name_line_edit_text_entered(new_text : String):
	undo_redo.create_action("Page name changed.")
	undo_redo.add_do_property(_page, "name", new_text)
	undo_redo.add_undo_property(_page, "name", _page.name)
	undo_redo.add_do_property(_entry_name_line_edit, "text", new_text)
	undo_redo.add_undo_property(_entry_name_line_edit, "text", _page.name)
	undo_redo.add_do_property(self, "name", new_text)
	undo_redo.add_undo_property(self, "name", _page.name)
	undo_redo.commit_action()

func _on_uri_segment_line_edit_text_entered(new_text : String):
	undo_redo.create_action("Page uri segment changed.")
	undo_redo.add_do_property(_page, "uri_segment", new_text)
	undo_redo.add_undo_property(_page, "uri_segment", _page.uri_segment)
	undo_redo.add_do_property(_uri_segment_line_edit, "text", new_text)
	undo_redo.add_undo_property(_uri_segment_line_edit, "text", _page.uri_segment)
	undo_redo.commit_action()

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
			set_page(web_node)
			#_page = web_node
			_wne_tool_bar_button.show()
			_wne_tool_bar_button.pressed = true
			#wne.switch_to_main_screen_tab(self)
		else:
			_wne_tool_bar_button.hide()
			#_page = null
			#add method to switch off to the prev screen
			#wne.switch_to_main_screen_tab(self)

func _on_add_entry_class_selected(cls_name : String) -> void:
	print(cls_name)

tool
extends PanelContainer

var WebPageEntryEditor : PackedScene = null

var _wne_tool_bar_button : Button = null

var _page : WebPage = null
var undo_redo : UndoRedo = null

var _entry_name_line_edit : LineEdit = null
var _uri_segment_line_edit : LineEdit = null
var _add_entry_popup : AcceptDialog = null
var _entries_container : Control = null
var _main_add_button : Button = null

var _entry_add_after : WebPageEntry = null

func set_page(page : WebPage):
	if _page:
		_page.disconnect("entries_changed", self, "on_page_entries_changed")
		
	_page = page
	
	if _page:
		_page.connect("entries_changed", self, "on_page_entries_changed")
	
	_entry_name_line_edit.text = page.name
	_uri_segment_line_edit.text = page.uri_segment
	
	recreate()

func recreate() -> void:
	clear()
	create_editors()

func create_editors() -> void:
	if _page.entries.size() > 0:
		_main_add_button.hide()
	
	for i in range(_page.entries.size()):
		var e : WebPageEntry = _page.entries[i]
		
		if e:
			var ee : Control = create_editor_for_entry(e)
			_entries_container.add_child(ee)

func create_editor_for_entry(entry : WebPageEntry) -> Control:
	var c : Control = WebPageEntryEditor.instance() as Control
	c.set_entry(entry, undo_redo)
	
	c.connect("entry_add_requested_after", self, "_on_entry_add_requested_after")
	c.connect("entry_move_up_requested", self, "_on_entry_move_up_requested")
	c.connect("entry_move_down_requested", self, "_on_entry_move_down_requested")
	c.connect("entry_delete_requested", self, "_on_entry_delete_requested")
	
	return c

func clear() -> void:
	_main_add_button.show()
	
	for i in range(_entries_container.get_child_count()):
		_entries_container.get_child(i).queue_free()

func add_entry(entry : WebPageEntry, after : WebPageEntry = null) -> void:
	undo_redo.create_action("Added web page entry")
	undo_redo.add_do_method(_page, "add_entry", entry, after)
	undo_redo.add_undo_method(_page, "remove_entry", entry)
	undo_redo.commit_action()

func remove_entry(entry : WebPageEntry) -> void:
	var after : WebPageEntry = _page.get_entry_before(entry)
	
	undo_redo.create_action("Added web page entry")
	undo_redo.add_do_method(_page, "remove_entry", entry)
	undo_redo.add_undo_method(_page, "add_entry", entry, after)
	undo_redo.commit_action()
	
func move_entry_up(entry : WebPageEntry) -> void:
	undo_redo.create_action("Added web page entry")
	undo_redo.add_do_method(_page, "move_entry_up", entry)
	undo_redo.add_undo_method(_page, "move_entry_down", entry)
	undo_redo.commit_action()
	
func move_entry_down(entry : WebPageEntry) -> void:
	undo_redo.create_action("Added web page entry")
	undo_redo.add_do_method(_page, "move_entry_down", entry)
	undo_redo.add_undo_method(_page, "move_entry_up", entry)
	undo_redo.commit_action()

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_entry_name_line_edit = get_node("MC/Name/EntryNameLineEdit")
		_entry_name_line_edit.connect("text_entered", self, "_on_entry_name_line_edit_text_entered")
		
		_uri_segment_line_edit = get_node("MC/URISegment/URISegmentLE")
		_uri_segment_line_edit.connect("text_entered", self, "_on_uri_segment_line_edit_text_entered")
		
		_add_entry_popup = get_node("Popups/AddEntryPopup")
		_add_entry_popup.connect("on_entry_class_selected", self, "_on_add_entry_class_selected")
		
		_entries_container = get_node("MC/EntriesContainer/MainVB/Entries")
		
		_main_add_button = get_node("MC/EntriesContainer/MainVB/MainAddButton")
		_main_add_button.connect("pressed", self, "_on_entry_add_requested")
		
		WebPageEntryEditor = ResourceLoader.load("res://addons/web_pages/editor/WebPageEntryEditor.tscn", "PackedScene") as PackedScene
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

func on_page_entries_changed() -> void:
	recreate()

func _on_add_entry_class_selected(cls_name : String) -> void:
	var entry : WebPageEntry = null
	
	if cls_name == "WebPageEntryTitleText":
		entry = WebPageEntryTitleText.new()
	elif cls_name == "WebPageEntryText":
		entry = WebPageEntryText.new()
				
	if !entry:
		PLogger.log_error("PageEditor: Couldn't create entry for: " + cls_name)
		return
		
	add_entry(entry, _entry_add_after)
	
func _on_entry_add_requested() -> void:
	_entry_add_after = null
	_add_entry_popup.popup_centered()
	
func _on_entry_add_requested_after(entry) -> void:
	_entry_add_after = entry
	_add_entry_popup.popup_centered()

func _on_entry_move_up_requested(entry) -> void:
	move_entry_up(entry)
	
func _on_entry_move_down_requested(entry) -> void:
	move_entry_down(entry)
	
func _on_entry_delete_requested(entry) -> void:
	remove_entry(entry)

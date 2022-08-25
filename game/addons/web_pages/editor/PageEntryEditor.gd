tool
extends VBoxContainer

var _entry : WebPageEntry = null

var _entry_type_label : Label = null

signal entry_add_requested_after(entry)
signal entry_move_up_requested(entry)
signal entry_move_down_requested(entry)
signal entry_delete_requested(entry)

func set_entry(entry : WebPageEntry) -> void:
	_entry = entry
	
	_entry_type_label.text = entry.get_class()

func _on_add_button_pressed():
	emit_signal("entry_add_requested_after", _entry)
	
func _on_up_button_pressed():
	emit_signal("entry_move_up_requested", _entry)
	
func _on_down_button_pressed():
	emit_signal("entry_move_down_requested", _entry)
	
func _on_delete_button_pressed():
	emit_signal("entry_delete_requested", _entry)
	
func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_entry_type_label = get_node("PC/VBC/TopBar/EntryTypeLabel")
		
		get_node("AddButton").connect("pressed", self, "_on_add_button_pressed")
		get_node("PC/VBC/TopBar/UpButton").connect("pressed", self, "_on_up_button_pressed")
		get_node("PC/VBC/TopBar/DownButton").connect("pressed", self, "_on_down_button_pressed")
		get_node("PC/VBC/TopBar/Delete").connect("pressed", self, "_on_delete_button_pressed")
		

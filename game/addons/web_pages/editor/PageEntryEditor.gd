tool
extends PanelContainer

var _entry : WebPageEntry = null

func set_entry(entry : WebPageEntry) -> void:
	_entry = entry

func _on_add_button_pressed():
	pass
	
func _on_up_button_pressed():
	pass
	
func _on_down_button_pressed():
	pass
	
func _on_delete_button_pressed():
	pass
	
func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		get_node("VBoxContainer/HBoxContainer/AddButton").connect("pressed", self, "_on_add_button_pressed")
		get_node("VBoxContainer/HBoxContainer/UpButton").connect("pressed", self, "_on_up_button_pressed")
		get_node("VBoxContainer/HBoxContainer/DownButton").connect("pressed", self, "_on_down_button_pressed")
		get_node("VBoxContainer/HBoxContainer/Delete").connect("pressed", self, "_on_delete_button_pressed")
		

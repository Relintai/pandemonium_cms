tool
extends AcceptDialog

signal on_entry_class_selected(entry_class)

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		get_ok().set_text("Close")
		
		get_node("HFlowContainer/AddTitleTextButton").connect("pressed", self, "_add_title_text_button_pressed")
		
func _add_title_text_button_pressed() -> void:
	emit_signal("on_entry_class_selected" , "WebPageEntryTitleText")

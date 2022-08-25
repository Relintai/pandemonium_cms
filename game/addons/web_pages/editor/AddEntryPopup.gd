tool
extends AcceptDialog

signal on_entry_class_selected(entry_class)

var _init : bool = false

func _notification(what):
	if what == NOTIFICATION_ENTER_TREE:
		if !_init:
			_init = true
			
			get_ok().set_text("Close")
			get_node("VBC/AddTitleTextButton").connect("pressed", self, "_add_title_text_button_pressed")
		
func _add_title_text_button_pressed() -> void:
	emit_signal("on_entry_class_selected" , "WebPageEntryTitleText")
	hide()

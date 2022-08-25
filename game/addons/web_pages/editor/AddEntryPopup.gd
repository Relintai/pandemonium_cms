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
			get_node("VBC/AddTextButton").connect("pressed", self, "_add_text_button_pressed")
			get_node("VBC/AddimageButton").connect("pressed", self, "_add_image_button_pressed")
		
func _add_title_text_button_pressed() -> void:
	emit_signal("on_entry_class_selected" , "WebPageEntryTitleText")
	hide()

func _add_text_button_pressed() -> void:
	emit_signal("on_entry_class_selected" , "WebPageEntryText")
	hide()

func _add_image_button_pressed() -> void:
	emit_signal("on_entry_class_selected" , "WebPageEntryImage")
	hide()

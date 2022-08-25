tool
extends MarginContainer

var _entry : WebPageEntryText = null
var undo_redo : UndoRedo = null

var _text_edit : TextEdit = null

func set_entry(entry : WebPageEntryText, pundo_redo : UndoRedo) -> void:
	undo_redo = pundo_redo
	_entry = entry
	_text_edit.text = _entry.text

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_text_edit = get_node("TextEdit")
		_text_edit.connect("text_changed", self, "_on_text_changed")

func _on_text_changed() -> void:
	var new_text : String = _text_edit.text
	
	undo_redo.create_action("Page text changed")
	undo_redo.add_do_property(_entry, "text", new_text)
	undo_redo.add_undo_property(_entry, "text", _entry.text)
	undo_redo.commit_action()

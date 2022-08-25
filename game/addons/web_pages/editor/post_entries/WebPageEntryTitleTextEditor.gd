tool
extends MarginContainer

var _entry : WebPageEntryTitleText = null
var undo_redo : UndoRedo = null

var _line_edit : LineEdit = null

func set_entry(entry : WebPageEntryTitleText, pundo_redo : UndoRedo) -> void:
	undo_redo = pundo_redo
	
	_entry = entry
	
	_line_edit.text = _entry.text

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_line_edit = get_node("LineEdit")
		
		_line_edit.connect("text_entered", self, "_on_line_edit")

func _on_line_edit(text : String) -> void:
	undo_redo.create_action("Page title text changed")
	undo_redo.add_do_property(_entry, "text", text)
	undo_redo.add_undo_property(_entry, "text", _entry.text)
	undo_redo.add_do_property(_line_edit, "text", text)
	undo_redo.add_undo_property(_line_edit, "text", _entry.text)
	undo_redo.commit_action()

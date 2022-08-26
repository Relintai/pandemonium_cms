tool
extends "res://addons/web_pages/classes/WebPageEntry.gd"
class_name WebPageEntryText, "res://addons/web_pages/icons/icon_web_page_entry_text.svg"

export(String) var text : String setget set_text, get_text
var compiled_text : String

func get_text() -> String:
	return text
	
func set_text(t : String) -> void:
	text = t
	
	compiled_text = text.replace("\n", "<br>")

func _render(request : WebServerRequest):
	request.body += compiled_text

func _get_editor() -> Control:
	var WebPageEntryTextEditor : PackedScene = ResourceLoader.load("res://addons/web_pages/editor/post_entries/WebPageEntryTextEditor.tscn", "PackedScene")
	return WebPageEntryTextEditor.instance() as Control

func get_page_entry_class_name() -> String:
	return "WebPageEntryText"

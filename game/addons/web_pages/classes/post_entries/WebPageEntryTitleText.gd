tool
extends "res://addons/web_pages/classes/WebPageEntry.gd"
class_name WebPageEntryTitleText, "res://addons/web_pages/icons/icon_web_page_entry_title_text.svg"

export(String) var text : String
export(int) var hsize : int = 1

func _render(request : WebServerRequest):
	request.body += "<h1>" + text + "</h1>"

func get_page_entry_class_name() -> String:
	return "WebPageEntryTitleText"


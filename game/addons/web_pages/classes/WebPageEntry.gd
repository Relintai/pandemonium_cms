tool
extends Resource
class_name WebPageEntry, "res://addons/web_pages/icons/icon_web_page_entry.svg"

func render(request : WebServerRequest):
	_render(request)
	
func _render(request : WebServerRequest):
	pass

func get_page_entry_class_name() -> String:
	return "WebPageEntry"

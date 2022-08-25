tool
extends Resource
class_name WebPageEntry, "res://addons/web_pages/icons/icon_web_page_entry.svg"

func handle_request(request : WebServerRequest) -> bool:
	return _handle_request(request)
	
func _handle_request(request : WebServerRequest) -> bool:
	return false

func render(request : WebServerRequest):
	_render(request)
	
func _render(request : WebServerRequest):
	pass

func get_page_entry_class_name() -> String:
	return "WebPageEntry"

tool
extends Resource
class_name WebPageEntry, "res://addons/web_pages/icons/icon_web_page_entry.svg"

export(int) var id : int = 0

func handle_request(request : WebServerRequest) -> bool:
	return _handle_request(request)
	
func _handle_request(request : WebServerRequest) -> bool:
	return false

func render(request : WebServerRequest):
	_render(request)
	
func _render(request : WebServerRequest):
	pass

func handle_edit(request : WebServerRequest) -> void:
	_handle_edit(request)
	
func _handle_edit(request : WebServerRequest) -> void:
	return

func render_edit_bar(request : WebServerRequest) -> void:
	_render_edit_bar(request)

func _render_edit_bar(request : WebServerRequest) -> void:
	var can_edit : bool = request.can_edit()
	var can_delete : bool = request.can_delete()
	
	if !can_delete && !can_delete:
		return
		
	var hb : HTMLBuilder = HTMLBuilder.new()
	
	hb.div()
	
	if can_edit:
		hb.a(request.get_url_root_add("edit/") + str(id)).f().w("Edit").ca().w(" ")
		hb.a(request.get_url_root_add("move_up/") + str(id)).f().w("Move Up").ca().w(" ")
		hb.a(request.get_url_root_add("move_down/") + str(id)).f().w("Move Down").ca().w(" ")
		
	if can_delete:
		hb.a(request.get_url_root_add("delete/") + str(id)).f().w("Delete").ca()
	
	hb.cdiv()
	
	request.body += hb.result

func get_page_entry_class_name() -> String:
	return "WebPageEntry"

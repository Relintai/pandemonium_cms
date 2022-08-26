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

func to_dict() -> Dictionary:
	return _to_dict()
	
func from_dict(dict : Dictionary) -> void:
	_from_dict(dict)

func _to_dict() -> Dictionary:
	return Dictionary()

func _from_dict(dict : Dictionary) -> void:
	pass

func handle_edit(request : WebServerRequest) -> WebPageEntry:
	return _handle_edit(request)
	
func _handle_edit(request : WebServerRequest) -> WebPageEntry:
	request.send_error(404)
	return null

func render_edit_bar(request : WebServerRequest) -> void:
	_render_edit_bar(request)

func _render_edit_bar(request : WebServerRequest) -> void:
	var can_edit : bool = request.can_edit()
	var can_delete : bool = request.can_delete()
	
	if !can_edit && !can_delete:
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

func get_editor() -> Control:
	return _get_editor()
	
func _get_editor() -> Control:
	return null

func get_page_entry_class_name() -> String:
	return "WebPageEntry"

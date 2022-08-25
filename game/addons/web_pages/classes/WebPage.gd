tool
extends WebNode
class_name WebPage, "res://addons/web_pages/icons/icon_web_page.svg"

export(bool) var sohuld_render_menu : bool = true
export(bool) var allow_web_interface_editing : bool = false

export(Array, Resource) var entries : Array

signal entries_changed()

#TODO fix webperm assign

func _handle_request(request : WebServerRequest):
	if request.get_remaining_segment_count() > 0:
		if allow_web_interface_editing:
			if web_editor_try_handle(request):
				return
			
		for i in range(entries.size()):
			var e : WebPageEntry = entries[i]
			
			if e && e.handle_request(request):
				return
				
		request.send_error(404)

	if sohuld_render_menu:
		render_menu(request)
	
	var should_render_edit_bar : bool = allow_web_interface_editing && (request.can_edit() || request.can_delete())

	for i in range(entries.size()):
		var e : WebPageEntry = entries[i]
		
		if e:
			if should_render_edit_bar:
				e.render_edit_bar(request)
				
			e.render(request)
	
	if request.can_create():
		var b : HTMLBuilder = HTMLBuilder.new()
		
		b.div()
		b.a(request.get_url_root_add("add")).f().w("+ Add New").ca()
		b.cdiv()
		request.body += b.result
	
	request.compile_and_send_body()

func web_editor_try_handle(request : WebServerRequest) -> bool:
	var path_segment : String = request.get_current_path_segment()
	
	if path_segment == "add":
		return web_editor_handle_add(request)
	elif path_segment == "edit":
		return web_editor_handle_edit(request)
	elif path_segment == "move_up":
		return web_editor_handle_move_up(request)
	elif path_segment == "move_down":
		return web_editor_handle_move_down(request)
	elif path_segment == "delete":
		return web_editor_handle_delete(request)
		
	return false

func web_editor_handle_add(request : WebServerRequest) -> bool:
	if !request.can_create():
		return false

	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		var t : String = request.get_parameter("type")
		
		var entry : WebPageEntry = null
		
		if !t.empty():
			if t == "title_text":
				entry = WebPageEntryTitleText.new()
			elif t == "text":
				entry = WebPageEntryText.new()
			elif t == "image":
				entry = WebPageEntryImage.new()
			
			if entry:
				add_entry(entry)
				request.send_redirect(request.get_url_root(), HTTPServerEnums.HTTP_STATUS_CODE_304_NOT_MODIFIED)
				return true
			else:
				request.body += "<div>Error processing your request!</div>"
		else:
			request.body += "<div>Error processing your request!</div>"
		
	
	if sohuld_render_menu:
		render_menu(request)
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	b.div()
	
	if true:
		b.form_post(request.get_url_root_current())
		b.csrf_tokenr(request)
		b.input_hidden("type", "title_text")
		b.input_submit("Create Title Text")
		b.cform()
		
		b.form_post(request.get_url_root_current())
		b.csrf_tokenr(request)
		b.input_hidden("type", "text")
		b.input_submit("Create Text")
		b.cform()
		
		b.form_post(request.get_url_root_current())
		b.csrf_tokenr(request)
		b.input_hidden("type", "image")
		b.input_submit("Create Image")
		b.cform()
	
	b.cdiv()
	
	request.body += b.result
	request.compile_and_send_body()
	
	return true
	
func web_editor_handle_edit(request : WebServerRequest) -> bool:
	if !request.can_edit():
		return false
		
	if request.get_remaining_segment_count() < 1:
		return false
		
	request.push_path()
	
	var resource_id_str : String = request.get_current_path_segment()
	
	if resource_id_str.empty() || !resource_id_str.is_valid_integer():
		# Todo either change the docs that this now returns "", or change it to "/"
		# not yet sure which one is better (empty is probably better)
		request.send_error(404)
		return true
	
	var resource_id : int = resource_id_str.to_int()
	
	var entry : WebPageEntry = get_entry_with_id(resource_id)
	
	if !entry:
		request.send_error(404)
		return true

	#entry.handle_edit(request)
	
	return true

func web_editor_handle_move_up(request : WebServerRequest) -> bool:
	if !request.can_edit():
		return false
		
	if request.get_remaining_segment_count() < 1:
		return false
		
	request.push_path()
	
	var resource_id_str : String = request.get_current_path_segment()
	
	if resource_id_str.empty() || !resource_id_str.is_valid_integer():
		# Todo either change the docs that this now returns "", or change it to "/"
		# not yet sure which one is better (empty is probably better)
		request.send_error(404)
		return true
	
	var resource_id : int = resource_id_str.to_int()
	
	var entry : WebPageEntry = get_entry_with_id(resource_id)
	
	if !entry:
		request.send_error(404)
		return true

	move_entry_up(entry)
	#TODO binding missing 2nd default param
	request.send_redirect(request.get_url_root_parent(1), HTTPServerEnums.HTTP_STATUS_CODE_302_FOUND)
	return true
	
func web_editor_handle_move_down(request : WebServerRequest) -> bool:
	if !request.can_edit():
		return false
		
	if request.get_remaining_segment_count() < 1:
		return false
		
	request.push_path()
	
	var resource_id_str : String = request.get_current_path_segment()
	
	if resource_id_str.empty() || !resource_id_str.is_valid_integer():
		# Todo either change the docs that this now returns "", or change it to "/"
		# not yet sure which one is better (empty is probably better)
		request.send_error(404)
		return true
	
	var resource_id : int = resource_id_str.to_int()
	
	var entry : WebPageEntry = get_entry_with_id(resource_id)
	
	if !entry:
		request.send_error(404)
		return true

	move_entry_down(entry)
	#TODO binding missing 2nd default param
	request.send_redirect(request.get_url_root_parent(1), HTTPServerEnums.HTTP_STATUS_CODE_302_FOUND)
	return true

func web_editor_handle_delete(request : WebServerRequest) -> bool:
	if !request.can_delete():
		return false
	
	if request.get_remaining_segment_count() < 1:
		return false
	
	request.push_path()
	
	var resource_id_str : String = request.get_current_path_segment()
	
	if resource_id_str.empty() || !resource_id_str.is_valid_integer():
		request.send_error(404)
		return true
	
	var resource_id : int = resource_id_str.to_int()
		
	var entry : WebPageEntry = get_entry_with_id(resource_id)
	
	if !entry:
		request.send_error(404)
		return true
	
	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		var accept : String = request.get_parameter("accept")
		
		if accept == "TRUE":
			remove_entry(entry)
			request.send_redirect(request.get_url_root(), HTTPServerEnums.HTTP_STATUS_CODE_304_NOT_MODIFIED)
			return true
		else:
			request.body += "<div>Error processing your request!</div>"
		
	if sohuld_render_menu:
		render_menu(request)
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	b.div()
	
	if true:
		entry.render(request)
		
		b.form_post(request.get_url_root_current())
		b.w("Are you sure you want to delete?")
		b.csrf_tokenr(request)
		b.input_hidden("accept", "TRUE")
		b.input_submit("Delete")
		b.cform()
	
	b.cdiv()
	
	request.body += b.result
	request.compile_and_send_body()
			
	return true

func get_next_id() -> int:
	var id : int = 0
	for i in range(entries.size()):
		var e : WebPageEntry = entries[i]
		
		if e:
			if e.id > id:
				id = e.id
				
	return id + 1

func add_entry(var entry : WebPageEntry, var after : WebPageEntry = null) -> void:
	var id : int = get_next_id()
	entry.id = id
	
	if after != null:
		for i in range(entries.size()):
			if entries[i] == after:
				entries.insert(i + 1, entry)
				break
	else:
		entries.push_back(entry)
		
	emit_signal("entries_changed")

func get_entry_with_index(index : int) -> WebPageEntry:
	if index < 0 || index >= entries.size():
		return null
		
	return entries[index]

func get_entry_with_id(id : int) -> WebPageEntry:
	for i in range(entries.size()):
		var e : WebPageEntry = entries[i]
		
		if e && e.id == id:
			return e
	
	return null

func remove_entry(var entry : WebPageEntry) -> void:
	entries.erase(entry)
	
	emit_signal("entries_changed")

func move_entry_up(var entry : WebPageEntry) -> void:
	# Skips checking the first entry (1, entries.size())
	for i in range(1, entries.size()):
		if entries[i] == entry:
			entries[i] = entries[i - 1]
			entries[i - 1] = entry
			emit_signal("entries_changed")
			return
	
func move_entry_down(var entry : WebPageEntry) -> void:
	# Skips checking the last entry (size() - 1)
	for i in range(entries.size() - 1):
		if entries[i] == entry:
			entries[i] = entries[i + 1]
			entries[i + 1] = entry
			emit_signal("entries_changed")
			return

func get_entry_before(var entry : WebPageEntry) -> WebPageEntry:
	if entries.size() < 2:
		return null
	
	if entries[0] == entry:
		return null
	
	for i in range(1, entries.size()):
		if entries[i] == entry:
			return entries[i - 1]
	
	return null

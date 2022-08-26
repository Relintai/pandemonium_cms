tool
extends WebNode
class_name WebPage, "res://addons/web_pages/icons/icon_web_page.svg"

export(bool) var sohuld_render_menu : bool = true
export(bool) var allow_web_interface_editing : bool = false

export(Array, Resource) var entries : Array

class WebPageEditCommand:
	var method : StringName
	var data : Array

var _pending_commands : Array = Array()
var _pending_array_mutex : Mutex = Mutex.new()

signal entries_changed()

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
				add_entry_command(entry)
				request.send_redirect(request.get_url_root())
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
		request.send_error(404)
		return true
	
	var resource_id : int = resource_id_str.to_int()
	
	var entry : WebPageEntry = get_entry_with_id(resource_id)
	
	if !entry:
		request.send_error(404)
		return true

	request.push_path()
	
	var e : WebPageEntry = entry.handle_edit(request)
	
	if e:
		edit_entry_command(entry, e)
	
	return true

func web_editor_handle_move_up(request : WebServerRequest) -> bool:
	if !request.can_edit():
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

	move_entry_up_command(entry)
	request.send_redirect(request.get_url_root_parent(1))
	return true

func web_editor_handle_move_down(request : WebServerRequest) -> bool:
	if !request.can_edit():
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

	move_entry_down_command(entry)
	request.send_redirect(request.get_url_root_parent(1))
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
			remove_entry_command(entry)
			request.send_redirect(request.get_url_root_parent())
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

func create_entry(cls_name : String) -> WebPageEntry:
	return _create_entry(cls_name)
	
func _create_entry(cls_name : String) -> WebPageEntry:
	var entry : WebPageEntry = null
	
	if cls_name == "WebPageEntryTitleText":
		entry = WebPageEntryTitleText.new()
	elif cls_name == "WebPageEntryText":
		entry = WebPageEntryText.new()
	elif cls_name == "WebPageEntryImage":
		entry = WebPageEntryImage.new()
	
	if !entry:
		PLogger.log_error("PageEditor: Couldn't create entry for: " + cls_name)
	
	return entry

func get_next_id() -> int:
	var id : int = 0
	for i in range(entries.size()):
		var e : WebPageEntry = entries[i]
		
		if e:
			if e.id > id:
				id = e.id
				
	return id + 1

func add_entry_command(var entry : WebPageEntry, var after : WebPageEntry = null) -> void:
	var command : WebPageEditCommand = WebPageEditCommand.new()
	
	command.method = "add_entry"
	command.data.push_back(entry)
	command.data.push_back(after)
	
	var request_write_lock : bool = false
	
	_pending_array_mutex.lock()
	_pending_commands.push_back(command)
	
	if _pending_commands.size() == 1:
		request_write_lock = true
		
	_pending_array_mutex.unlock()
	
	if request_write_lock:
		request_write_lock()
	
func remove_entry_command(var entry : WebPageEntry) -> void:
	var command : WebPageEditCommand = WebPageEditCommand.new()
	
	command.method = "remove_entry"
	command.data.push_back(entry)
	
	var request_write_lock : bool = false
	
	_pending_array_mutex.lock()
	_pending_commands.push_back(command)
	
	if _pending_commands.size() == 1:
		request_write_lock = true
		
	_pending_array_mutex.unlock()
	
	if request_write_lock:
		request_write_lock()
		
func move_entry_up_command(var entry : WebPageEntry) -> void:
	var command : WebPageEditCommand = WebPageEditCommand.new()
	
	command.method = "move_entry_up"
	command.data.push_back(entry)
	
	var request_write_lock : bool = false

	_pending_array_mutex.lock()
	_pending_commands.push_back(command)

	if _pending_commands.size() == 1:
		request_write_lock = true
		
	_pending_array_mutex.unlock()
	
	if request_write_lock:
		request_write_lock()
		
func move_entry_down_command(var entry : WebPageEntry) -> void:
	var command : WebPageEditCommand = WebPageEditCommand.new()
	
	command.method = "move_entry_down"
	command.data.push_back(entry)
	
	var request_write_lock : bool = false
	
	_pending_array_mutex.lock()
	_pending_commands.push_back(command)
	
	if _pending_commands.size() == 1:
		request_write_lock = true
		
	_pending_array_mutex.unlock()
	
	if request_write_lock:
		request_write_lock()
		
	
func edit_entry_command(var entry : WebPageEntry, var data : WebPageEntry) -> void:
	var command : WebPageEditCommand = WebPageEditCommand.new()
	
	command.method = "replace_entry"
	command.data.push_back(entry)
	command.data.push_back(data)
	
	var request_write_lock : bool = false
	
	_pending_array_mutex.lock()
	_pending_commands.push_back(command)
	
	if _pending_commands.size() == 1:
		request_write_lock = true
		
	_pending_array_mutex.unlock()
	
	if request_write_lock:
		request_write_lock()

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
		
	if !entry.is_connected("changed", self, "_on_entry_changed"):
		entry.connect("changed", self, "_on_entry_changed")
		
	on_entries_changed()

func get_entry_with_index(index : int) -> WebPageEntry:
	if index < 0 || index >= entries.size():
		return null
		
	return entries[index]

func get_entry_with_id(id : int) -> WebPageEntry:
	for i in range(entries.size()):
		var e : WebPageEntry = entries[i]

		if e:
			if (e.id == id):
				return e
	
	return null

func remove_entry(var entry : WebPageEntry) -> void:
	if entry && !entry.is_connected("changed", self, "_on_entry_changed"):
		entry.connect("changed", self, "_on_entry_changed")
					
	entries.erase(entry)
	
	on_entries_changed()

func move_entry_up(var entry : WebPageEntry) -> void:
	# Skips checking the first entry (1, entries.size())
	for i in range(1, entries.size()):
		if entries[i] == entry:
			entries[i] = entries[i - 1]
			entries[i - 1] = entry
			on_entries_changed()
			return

func move_entry_down(var entry : WebPageEntry) -> void:
	# Skips checking the last entry (size() - 1)
	for i in range(entries.size() - 1):
		if entries[i] == entry:
			entries[i] = entries[i + 1]
			entries[i + 1] = entry
			on_entries_changed()
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

func replace_entry(var entry : WebPageEntry, var data : WebPageEntry) -> void:
	for i in range(entries.size()):
		if entries[i] == entry:
			if entry && entry.is_connected("changed", self, "_on_entry_changed"):
				entry.disconnect("changed", self, "_on_entry_changed")
			
			entries[i] = data

			if data && !data.is_connected("changed", self, "_on_entry_changed"):
				data.connect("changed", self, "_on_entry_changed")

			on_entries_changed()
			return

func clear_entries() -> void:
	for i in range(entries.size()):
		var e : WebPageEntry = entries[i]

		if e && e.is_connected("changed", self, "_on_entry_changed"):
				e.disconnect("changed", self, "_on_entry_changed")
	
	entries.clear()

func save_data():
	_save_data()

func _save_data():
	if !Engine.editor_hint && allow_web_interface_editing:
		var data : Dictionary = Dictionary()
		
		data["entries_size"] = entries.size()
		var entries_data : Array = Array()
		
		for i in range(entries.size()):
			var e : WebPageEntry = entries[i]

			if e:
				var ed : Dictionary = Dictionary()
				
				ed["index"] = i
				ed["class"] = e.get_page_entry_class_name()
				ed["data"] = e.to_dict()
				
				entries_data.push_back(ed)
		
		data["entries"] = entries_data
		
		# TODO add get_uri(), get_root_uri(), etc helpers to WebNode
		var wn : WebNode = self
		var wnpath : String
		
		while wn:
			wnpath = wn.uri_segment + "_" + wnpath
			wn = wn.get_parent_webnode()
		
		if !wnpath.empty():
			wnpath = "user://" + wnpath + ".json"
			
			var f : File = File.new()
			f.open(wnpath, File.WRITE)
			f.store_string(to_json(data))
			f.close()

func load_data():
	_load_data()

func _load_data():
	if !Engine.editor_hint && allow_web_interface_editing:
		var data : Dictionary = Dictionary()
		var wn : WebNode = self
		var wnpath : String
		
		while wn:
			wnpath = wn.uri_segment + "_" + wnpath
			wn = wn.get_parent_webnode()
		
		if !wnpath.empty():
			wnpath = "user://" + wnpath + ".json"
			
			var f : File = File.new()
			
			if !f.file_exists(wnpath):
				return
			
			f.open(wnpath, File.READ)
			var dr : String = f.get_as_text()
			f.close()
			
			var jp : JSONParseResult = JSON.parse(dr)
			
			if jp.error != OK:
				print("jp.error != OK")
				return
				
			data = jp.result
		
		if !data.has("entries_size") || !data.has("entries"):
			return
		
		clear_entries()
		entries.resize(data["entries_size"])
		var entries_data : Array = data["entries"]
		
		for i in range(entries.size()):
			var ed : Dictionary = entries_data[i]
			
			var index : int = ed["index"]
			
			if index < 0 || index >= entries.size():
				print("ERROR! index < 0 || index >= entries.size()")
				return
			
			var cls : String = ed["class"]
			var edata : Dictionary = ed["data"]
			
			var e : WebPageEntry = create_entry(cls)
			
			if e:
				e.from_dict(edata)
				e.id = index
				entries[index] = e
				
				e.connect("changed", self, "_on_entry_changed")
				
func _notification(what):
	if what == NOTIFICATION_READY:
		load_data()
		
		if !Engine.editor_hint:
			for i in range(entries.size()):
				var e : WebPageEntry = entries[i]
				
				if e && !e.is_connected("changed", self, "_on_entry_changed"):
					e.connect("changed", self, "_on_entry_changed")
	elif what == NOTIFICATION_WEB_NODE_WRITE_LOCKED:
		if !Engine.editor_hint:
			_pending_array_mutex.lock()
			
			var changed : bool = _pending_commands.size() > 0
			
			for i in range(_pending_commands.size()):
				var e : WebPageEditCommand = _pending_commands[i] as WebPageEditCommand
				
				callv(e.method, e.data)
			
			_pending_commands.clear()

			_pending_array_mutex.unlock()
			
			if changed:
				save_data()
				on_entries_changed()

func _on_entry_changed():
	on_entries_changed()
	
func on_entries_changed():
	emit_signal("entries_changed")
	

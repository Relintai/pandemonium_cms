extends WebServer

# Maybe WebNodes should get a method like get_property_list?
# (like get_uri_list, get_served_folder_list, get_served_file_list)
# Would likely be good for other things, like cleanups aswell.

var StaticWebServerRequest = preload("res://StaticWebServerRequest.gd")

func _ready() -> void:
	start()

func prepare_dir(export_folder : String) -> void:
	var dir : Directory = Directory.new()
	if dir.dir_exists(export_folder):
		OS.move_to_trash(export_folder)
	
	dir.make_dir_recursive(export_folder)
	
func make_dir_recursive(folder : String) -> void:
	var dir : Directory = Directory.new()
	dir.make_dir_recursive(folder)

func export_web_project() -> void:
	if !get_web_root():
		print("!get_web_root()")
		return
	
	var export_folder : String = OS.get_user_data_dir().append_path("export/")
	
	prepare_dir(export_folder)

	evaluate_web_node(get_web_root(), "/", export_folder, 0)

func copy_folder(path_from : String, path_to : String) -> void:
	var dir : Directory = Directory.new()
	dir.make_dir_recursive(path_to)
	
	if dir.open(path_from) == OK:
		dir.list_dir_begin(true)
		var file_name : String = dir.get_next()
		while !file_name.empty():
			if dir.current_is_dir():
				copy_folder(path_from.append_path(file_name), path_to.append_path(file_name))
			else:
				dir.copy(path_from.plus_file(file_name), path_to.plus_file(file_name))

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: %s " % path_from)

func copy_file(path_from : String, path_to : String) -> void:
	var dir : Directory = Directory.new()
	dir.make_dir_recursive(path_to.get_base_dir())
	
	dir.copy(path_from, path_to)

func write_index(n : WebNode, path : String, uri : String, level : int) -> void:
	var request : WebServerRequestScriptable = StaticWebServerRequest.new()
	request._parser_path = uri
	request._set_server(self)
	request._set_web_root(get_web_root())
	request.setup_url_stack()
	
	for i in range(level):
		request.push_path()
	
	n.handle_request(request)
	
	var file : File = File.new()
	file.open(path.plus_file("index.html"), File.WRITE)
	file.store_string(request.compiled_body)
	file.close()
	

func evaluate_web_node(n : WebNode, web_node_path : String, path : String, level : int) -> void:
	make_dir_recursive(path)
	
	if n is WebRoot:
		if n.www_root_path != "":
			copy_folder(n.www_root_path, path)
			
		for c in n.get_children():
			if c is WebNode:
				if c.uri_segment != "/":
					continue
				
				write_index(c, path, web_node_path, level)
				break
	else:
		write_index(n, path, web_node_path, level)
		
	if n.has_method("_get_served_file_list"):
		var file_arr : Array = Array()
		n._get_served_file_list(file_arr)
		
		for i in range(file_arr.size()):
			var f : Array = file_arr[i]
			
			copy_file(f[0], path.plus_file(f[1]))
	
	level += 1
	
	for c in n.get_children():
		if c is WebNode:
			if c.uri_segment.empty() || c.uri_segment == "/":
				continue
				
			evaluate_web_node(c, web_node_path.append_path(c.uri_segment), path.append_path(c.uri_segment), level)


func _on_ExportButton_pressed() -> void:
	export_web_project()

func _on_OpenFolderButton_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())

extends WebServerSimple




func _start() -> void:
	get_node("WebRoot").www_root_path = OS.get_user_data_dir().append_path("export/")
	
	._start()

extends WebRoot

func _handle_request_main(request : WebServerRequest) -> void:
	#if (process_middlewares(request)):
	#	return;

	#if (web_permission.is_valid()):
	#	if (web_permission.activate(request)):
	#		return;
	
	#handle_request(request);
	
	# handle files first
	if (try_send_wwwroot_file_gd(request)):
		return;

	handle_request(request);

	# normal routing
#	if (!routing_enabled):
#		handle_request(request);
#		return;
#
#	if (!try_route_request_to_children(request)):
#		handle_request(request);

func try_send_wwwroot_file_gd(request : WebServerRequest) -> bool:
	var path : String = request.get_path_full();
	path = path.to_lower();

	var file_indx : int = www_root_file_cache.wwwroot_get_file_index(path);

	if (file_indx != -1):
		send_file(www_root_file_cache.wwwroot_get_file_orig_path(file_indx), request);

		return true;
	else:
		path = path.plus_file("index.html")
		
		file_indx = www_root_file_cache.wwwroot_get_file_index(path);

		if (file_indx != -1):
			send_file(www_root_file_cache.wwwroot_get_file_orig_path(file_indx), request);

			return true;

	return false;

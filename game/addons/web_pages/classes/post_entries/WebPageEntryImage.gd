tool
extends "res://addons/web_pages/classes/WebPageEntry.gd"
class_name WebPageEntryImage, "res://addons/web_pages/icons/icon_web_page_entry_image.svg"

export(String) var image_path : String
export(String) var image_url : String
export(String) var alt : String
export(Vector2i) var image_size : Vector2i = Vector2i()

func _handle_request(request : WebServerRequest) -> bool:
	if image_url.empty() || image_path.empty():
		return false
		
	var file : File = File.new()
	
	#if !file.file_exists(image_path):
	#	return false
	
	if request.get_current_path_segment() == image_url:
		request.send_file(image_path)
		# handled
		return true 
		
	return false

func _render(request : WebServerRequest):
	if image_url.empty() || image_path.empty():
		return
	
	request.body += '<img src="' + request.get_url_root() + image_url + '"'
	
	if !alt.empty():
		request.body += ' alt="' + alt + '"'
		
	if image_size.x > 0:
		request.body += ' width="' + str(image_size.x) + '"'
		
	if image_size.y > 0:
		request.body += ' height="' + str(image_size.y) + '"'
		
	request.body += '>'

func get_page_entry_class_name() -> String:
	return "WebPageEntryImage"
	

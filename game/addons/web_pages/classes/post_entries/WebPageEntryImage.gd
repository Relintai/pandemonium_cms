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

func _handle_edit(request : WebServerRequest) -> void:
	if !request.can_edit():
		#should be ERR_FAIL_COND
		return
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		image_url = request.get_parameter("image_url")
		alt = request.get_parameter("image_alt")
		
		var imgssx : String = request.get_parameter("image_size_x")
		var imgssy : String = request.get_parameter("image_size_y")
		
		image_size = Vector2i(imgssx.to_int(), imgssy.to_int())
		
		if request.get_file_count() > 0:
			var fd : PoolByteArray = request.get_file_data(0)
			
			if fd.size() > 0:
				var fn : String = request.get_file_file_name(0)
				var f : File = File.new()
				f.open("user://" + fn, File.WRITE)
				f.store_buffer(fd)
				f.close()
				
				image_path = "user://" + fn
			
		
		#b.div().f().w("Save successful!").cdiv()
		emit_changed()
		request.send_redirect(request.get_url_root_parent(2))

	b.div().f().a(request.get_url_root_parent(2)).f().w("<-- back").ca().cdiv()
	b.br()
	
	b.h1().f().w("Editing: Image").ch1()
	b.br()

	b.form_post(request.get_url_root()).enctype_multipart_form_data()
	b.csrf_tokenr(request)
	
	b.label().fora("image_url").f().w("Image URL:").clabel().br()
	b.input_text("image_url", image_url, "", "", "image_url")
	b.br()
	
	b.label().fora("image_alt").f().w("Image alt:").clabel().br()
	b.input_text("image_alt", alt, "", "", "image_alt")
	b.br()
	
	b.label().fora("image_size_x").f().w("Image Width (Optional):").clabel().br()
	b.input_number("image_size_x", "0", "999990", "", "image_size_x").value(str(image_size.x))
	b.br()
	
	b.label().fora("image_size_y").f().w("Image Heigth (Optional):").clabel().br()
	b.input_number("image_size_y", "0", "999990", "", "image_size_y").value(str(image_size.y))
	b.br()
	
	b.label().fora("image").f().w("Add / Replace Image:").clabel().br()
	b.input_file("image", "image/png, image/jpeg", "", "image")
	b.br()
	
	b.input_submit("Save")
	b.cform()
	b.br()
	
	b.br()
	
	request.body += b.result
	request.compile_and_send_body()

func _get_editor() -> Control:
	var WebPageEntryImageEditor : PackedScene =  ResourceLoader.load("res://addons/web_pages/editor/post_entries/WebPageEntryImageEditor.tscn", "PackedScene")
	return WebPageEntryImageEditor.instance() as Control

func get_page_entry_class_name() -> String:
	return "WebPageEntryImage"
	

tool
extends "res://addons/web_pages/classes/WebPageEntry.gd"
class_name WebPageEntryTitleText, "res://addons/web_pages/icons/icon_web_page_entry_title_text.svg"

export(String) var text : String
export(int) var hsize : int = 1

func _render(request : WebServerRequest):
	request.body += "<h1>" + text + "</h1>"

func get_page_entry_class_name() -> String:
	return "WebPageEntryTitleText"
	
func _handle_edit(request : WebServerRequest) -> WebPageEntry:
	if !request.can_edit():
		#should be ERR_FAIL_COND
		return null
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		var e : WebPageEntry = duplicate()
		
		e.text = request.get_parameter("text")

		request.send_redirect(request.get_url_root_parent(2))
		
		return e
		
	b.div().f().a(request.get_url_root_parent(2)).f().w("<-- back").ca().cdiv()
	b.br()
	
	b.h1().f().w("Editing: Title Text").ch1()
	b.br()

	b.form_post(request.get_url_root())
	b.csrf_tokenr(request)
	b.label().fora("text").f().w("Text: ").clabel()
	b.input_text("text", text, "", "", "text")
	b.input_submit("Save")
	b.cform()
	
	request.body += b.result
	request.compile_and_send_body()
	return null

func _get_editor() -> Control:
	var WebPageEntryTitleTextEditor : PackedScene = ResourceLoader.load("res://addons/web_pages/editor/post_entries/WebPageEntryTitleTextEditor.tscn", "PackedScene")
	return WebPageEntryTitleTextEditor.instance() as Control

tool
extends "res://addons/web_pages/classes/WebPageEntry.gd"
class_name WebPageEntryText, "res://addons/web_pages/icons/icon_web_page_entry_text.svg"

export(String) var text : String setget set_text, get_text
var compiled_text : String

func get_text() -> String:
	return text
	
func set_text(t : String) -> void:
	text = t
	
	compiled_text = text.replace("\n", "<br>")

func _render(request : WebServerRequest):
	request.body += compiled_text

func _handle_edit(request : WebServerRequest) -> void:
	if !request.can_edit():
		#should be ERR_FAIL_COND
		return
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		set_text(request.get_parameter("text"))
		
		#b.div().f().w("Save successful!").cdiv()
		emit_changed()
		request.send_redirect(request.get_url_root_parent(2))
		
	b.div().f().a(request.get_url_root_parent(2)).f().w("<-- back").ca().cdiv()
	b.br()
	
	b.h1().f().w("Editing: Text").ch1()
	b.br()

	b.form_post(request.get_url_root())
	b.csrf_tokenr(request)
	b.label().fora("text").f().w("Text: ").clabel().br()
	b.textarea("text", "", "text").rows("50").cols("80").f().w(text).ctextarea()
	b.br()
	b.input_submit("Save")
	b.cform()
	b.br()
	b.br()
	
	request.body += b.result
	request.compile_and_send_body()

func _get_editor() -> Control:
	var WebPageEntryTextEditor : PackedScene = ResourceLoader.load("res://addons/web_pages/editor/post_entries/WebPageEntryTextEditor.tscn", "PackedScene")
	return WebPageEntryTextEditor.instance() as Control

func get_page_entry_class_name() -> String:
	return "WebPageEntryText"

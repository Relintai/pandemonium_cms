tool
extends PanelContainer

signal blog_post_edit_requested(post)

var undo_redo : UndoRedo = null

var _post : WebBlogPost

func set_post(post : WebBlogPost) -> void:
	_post = post
	
	update()

func update() -> void:
	if _post:
		get_node("HBC/PostName").text = _post.name
	else:
		get_node("HBC/PostName").text = ""

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		var _edit_button : Button = get_node("HBC/EditButton")
		
		_edit_button.connect("pressed", self, "_on_edit_button_pressed")
		
func _on_edit_button_pressed() -> void:
	if _post:
		emit_signal("blog_post_edit_requested", _post)

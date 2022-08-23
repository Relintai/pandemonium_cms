tool
extends VBoxContainer

var _post : WebBlogPost = null
var undo_redo : UndoRedo = null

func set_post(post : WebBlogPost):
	_post = post
	get_node("HBoxContainer/PostNameLE").text = post.name
	name = post.name
	
func _on_PostNameLE_text_entered(new_text : String):
	var le : LineEdit = get_node("HBoxContainer/PostNameLE")
	
	undo_redo.create_action("Post name changed.")
	undo_redo.add_do_property(_post, "name", new_text)
	undo_redo.add_undo_property(_post, "name", _post.name)
	undo_redo.add_do_property(le, "text", new_text)
	undo_redo.add_undo_property(le, "text", _post.name)
	undo_redo.add_do_property(self, "name", new_text)
	undo_redo.add_undo_property(self, "name", _post.name)
	undo_redo.commit_action()

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		var le : LineEdit = get_node("HBoxContainer/PostNameLE")
		le.connect("text_entered", self, "_on_PostNameLE_text_entered")

tool
extends VBoxContainer

var _post : WebBlogPost = null
var undo_redo : UndoRedo = null

func set_post(post : WebBlogPost):
	_post = post
	get_node("HBoxContainer/PostNameLE").text = post.post_name
	name = post.post_name
	
func _on_PostNameLE_text_entered(new_text : String):
	var le : LineEdit = get_node("HBoxContainer/PostNameLE")
	
	undo_redo.create_action("Post name changed.")
	undo_redo.add_do_property(_post, "post_name", new_text)
	undo_redo.add_undo_property(_post, "post_name", _post.post_name)
	undo_redo.add_do_property(le, "text", new_text)
	undo_redo.add_undo_property(le, "text", _post.post_name)
	undo_redo.add_do_property(self, "name", new_text)
	undo_redo.add_undo_property(self, "name", _post.post_name)
	undo_redo.commit_action()

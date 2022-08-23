tool
extends WebNode
class_name WebBlog, "res://addons/web_blog/icons/icon_web_blog.svg"

func add_post(post : WebBlogPost) -> void:
	if (get_child_count() > 0):
		add_child_below_node(get_child(0), post)
		move_child(get_child(1), 0)
	else:
		add_child(post)

	if Engine.editor_hint:
		post.owner = get_tree().edited_scene_root
	
func remove_post(post : WebBlogPost) -> void:
	remove_child(post)

# Temp hack for undoredo
func null_method() -> void:
	pass

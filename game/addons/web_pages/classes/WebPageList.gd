tool
extends WebNode
class_name WebPageList, "res://addons/web_page_list/icons/icon_web_page_list.svg"

func add_post(post : WebPage) -> void:
	if (get_child_count() > 0):
		add_child_below_node(get_child(0), post)
		move_child(get_child(1), 0)
	else:
		add_child(post)

	if Engine.editor_hint:
		post.owner = get_tree().edited_scene_root
	
func remove_post(post : WebPage) -> void:
	remove_child(post)

# Temp hack for undoredo
func null_method() -> void:
	pass

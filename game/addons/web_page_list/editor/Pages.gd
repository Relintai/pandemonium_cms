tool
extends VBoxContainer

signal new_post_request
signal blog_post_edit_requested(post)

var undo_redo : UndoRedo = null

var _blog : WebPageList = null

func create_post_list() -> void:
	if !_blog:
		return
	
	var _entry_container : VBoxContainer = get_node("ScrollContainer/OutsideVBC/Entries")
	
	var PostListEntry : PackedScene = ResourceLoader.load("res://addons/web_pages/editor/PostListEntry.tscn")
	
	for i in range(_blog.get_child_count()):
		var c : Node = _blog.get_child(i)
		
		if !(c is WebPage):
			continue
		
		var wbp : WebPage = c as WebPage
		
		var entry = PostListEntry.instance()
		entry.undo_redo = undo_redo
		entry.set_post(wbp)
		entry.connect("blog_post_edit_requested", self, "_on_blog_post_edit_requested")
		_entry_container.add_child(entry)
		

func clear() -> void:
	var _entry_container : VBoxContainer = get_node("ScrollContainer/OutsideVBC/Entries")
	
	for i in range(_entry_container.get_child_count()):
		_entry_container.get_child(i).queue_free()

func recreate() -> void:
	clear()
	create_post_list()

func set_web_pages(blog : WebPageList) -> void:
	if _blog == blog:
		return
		
	_blog = blog
	
	recreate()

func _on_blog_post_edit_requested(post) -> void:
	emit_signal("blog_post_edit_requested", post)

func _on_NewPostButton_pressed():
	emit_signal("new_post_request")

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			recreate()

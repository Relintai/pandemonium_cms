tool
extends WebNode
class_name WebBlog, "res://addons/web_blog/icons/icon_web_blog.svg"

export(Array, Resource) var posts : Array

func add_post(post : WebBlogPost) -> void:
	posts.push_back(post)
	
func remove_post(post : WebBlogPost) -> void:
	posts.erase(post)

# Temp hack for undoredo
func null_method() -> void:
	pass

tool
extends VBoxContainer

signal new_post_request

func _on_NewPostButton_pressed():
	emit_signal("new_post_request")

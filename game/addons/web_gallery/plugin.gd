tool
extends EditorPlugin

var gallery_icon : Texture = null

#func _ready():
#	gallery_icon = ResourceLoader.load("res://addons/web_gallery/icons/icon_gallery.svg", )

func enable_plugin() ->void:
	pass

func disable_plugin() ->void:
	pass

func get_plugin_name() -> String:
	return "WebGalleryEditorPlugin"

#func handles(object: Object) -> bool:
#	return false
	
#func has_main_screen() -> bool:
#	return false
	
#func make_visible(visible: bool) -> void:
#	pass



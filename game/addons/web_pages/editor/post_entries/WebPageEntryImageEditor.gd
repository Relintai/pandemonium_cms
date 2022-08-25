tool
extends MarginContainer

var _entry : WebPageEntryImage = null
var undo_redo : UndoRedo = null

var _image_path_line_edit : LineEdit = null
var _image_url_line_edit : LineEdit = null
var _image_alt_line_edit : LineEdit = null
var _image_width_sb : SpinBox = null
var _image_heigth_sb : SpinBox = null
var _image_preview : TextureRect = null

func set_entry(entry : WebPageEntryImage, pundo_redo : UndoRedo) -> void:
	undo_redo = pundo_redo
	_entry = entry
	
	_image_path_line_edit.text = _entry.image_path
	_image_url_line_edit.text = _entry.image_url
	_image_alt_line_edit.text = _entry.alt
	_image_width_sb.value = _entry.image_size.x
	_image_heigth_sb.value = _entry.image_size.y
	
	refresh_image()

func refresh_image() -> void:
	_image_preview.texture = null
	
	if _entry.image_path.empty():
		return
		
	var file : File = File.new()
	
	if !file.file_exists(_entry.image_path):
		PLogger.log_warning("Image Editor: Image file doesn't exists.")
		return
	
	var img : Image = ResourceLoader.load(_entry.image_path, "Image")
	
	if !img:
		PLogger.log_warning("Image Editor: Couldn't load Image file!")
		return
		
	var t : ImageTexture = ImageTexture.new()
	t.create_from_image(img)
	
	_image_preview.texture = t
	

func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_image_path_line_edit = get_node("VBoxContainer/ImagePath/ImagePathLE")
		_image_url_line_edit = get_node("VBoxContainer/ImageURL/ImageURLLE")
		_image_alt_line_edit = get_node("VBoxContainer/ImageAlt/ImageAltLE")
		_image_width_sb = get_node("VBoxContainer/ImageWH/ImageWidthSB")
		_image_heigth_sb = get_node("VBoxContainer/ImageWH/ImageHeigthSB")
		_image_preview = get_node("VBoxContainer/HBoxContainer/ImagePreview")
		
		_image_path_line_edit.connect("text_entered", self, "_on_image_path_le_text_entered")
		_image_url_line_edit.connect("text_entered", self, "_on_image_url_le_text_entered")
		_image_alt_line_edit.connect("text_entered", self, "_on_image_alt_le_text_entered")
		_image_width_sb.connect("value_changed", self, "_image_width_sb_value_changed")
		_image_heigth_sb.connect("value_changed", self, "_image_heigth_sb_value_changed")

func _on_image_path_le_text_entered(text : String) -> void:
	undo_redo.create_action("Image path text changed")
	undo_redo.add_do_property(_entry, "image_path", text)
	undo_redo.add_undo_property(_entry, "image_path", _entry.image_path)
	undo_redo.add_do_property(_image_path_line_edit, "text", text)
	undo_redo.add_undo_property(_image_path_line_edit, "text", _entry.image_path)
	undo_redo.commit_action()
	
	refresh_image()

func _on_image_url_le_text_entered(text : String) -> void:
	undo_redo.create_action("Image URL text changed")
	undo_redo.add_do_property(_entry, "image_url", text)
	undo_redo.add_undo_property(_entry, "image_url", _entry.image_url)
	undo_redo.add_do_property(_image_url_line_edit, "text", text)
	undo_redo.add_undo_property(_image_url_line_edit, "text", _entry.image_url)
	undo_redo.commit_action()
	
func _on_image_alt_le_text_entered(text : String) -> void:
	undo_redo.create_action("Image alt text changed")
	undo_redo.add_do_property(_entry, "alt", text)
	undo_redo.add_undo_property(_entry, "alt", _entry.alt)
	undo_redo.add_do_property(_image_alt_line_edit, "text", text)
	undo_redo.add_undo_property(_image_alt_line_edit, "text", _entry.alt)
	undo_redo.commit_action()

func _image_width_sb_value_changed(val : float) -> void:
	var imgsize_orig : Vector2i = _entry.image_size
	var imgsize_new : Vector2i = _entry.image_size
	imgsize_new.x = val
	
	undo_redo.create_action("Image width changed")
	undo_redo.add_do_property(_entry, "image_size", imgsize_new)
	undo_redo.add_undo_property(_entry, "image_size", imgsize_orig)
	undo_redo.add_do_property(_image_alt_line_edit, "value", imgsize_new.x)
	undo_redo.add_undo_property(_image_alt_line_edit, "value", imgsize_orig.x)
	undo_redo.commit_action()

func _image_heigth_sb_value_changed(val : float) -> void:
	var imgsize_orig : Vector2i = _entry.image_size
	var imgsize_new : Vector2i = _entry.image_size
	imgsize_new.y = val
	
	undo_redo.create_action("Image width changed")
	undo_redo.add_do_property(_entry, "image_size", imgsize_new)
	undo_redo.add_undo_property(_entry, "image_size", imgsize_orig)
	undo_redo.add_do_property(_image_alt_line_edit, "value", imgsize_new.y)
	undo_redo.add_undo_property(_image_alt_line_edit, "value", imgsize_orig.y)
	undo_redo.commit_action()


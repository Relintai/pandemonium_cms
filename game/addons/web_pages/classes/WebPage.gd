tool
extends WebNode
class_name WebPage, "res://addons/web_pages/icons/icon_web_page.svg"

export(bool) var sohuld_render_menu : bool = true

export(Array, Resource) var entries : Array

signal entries_changed()

func _handle_request(request : WebServerRequest):
	if sohuld_render_menu:
		render_menu(request)
		
	for i in range(entries.size()):
		var e : WebPageEntry = entries[i]
		
		if e:
			e.render(request)
			
	request.compile_and_send_body()

func add_entry(var entry : WebPageEntry, var after : WebPageEntry = null) -> void:
	if after != null:
		for i in range(entries.size()):
			if entries[i] == after:
				entries.insert(i + 1, entry)
				break
	else:
		entries.push_back(entry)
		
	emit_signal("entries_changed")

func remove_entry(var entry : WebPageEntry) -> void:
	entries.erase(entry)
	
	emit_signal("entries_changed")

func move_entry_up(var entry : WebPageEntry) -> void:
	# Skips checking the first entry (1, entries.size())
	for i in range(1, entries.size()):
		if entries[i] == entry:
			entries[i] = entries[i - 1]
			entries[i - 1] = entry
			emit_signal("entries_changed")
			return
	
func move_entry_down(var entry : WebPageEntry) -> void:
	# Skips checking the last entry (size() - 1)
	for i in range(entries.size() - 1):
		if entries[i] == entry:
			entries[i] = entries[i + 1]
			entries[i + 1] = entry
			emit_signal("entries_changed")
			return

func get_entry_before(var entry : WebPageEntry) -> WebPageEntry:
	if entries.size() < 2:
		return null
	
	if entries[0] == entry:
		return null
	
	for i in range(1, entries.size()):
		if entries[i] == entry:
			return entries[i - 1]
	
	return null

extends WebPermission

export(int, FLAGS, "VIEW", "CREATE", "EDIT", "DELETE") var permissions : int = 1

func _get_permissions(request : WebServerRequest):
	return permissions

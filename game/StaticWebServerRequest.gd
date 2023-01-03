extends WebServerRequestScriptable

enum ResponseType {
	RESPONSE_TYPE_NONE = 0,
	RESPONSE_TYPE_NORMAL = 1,
	RESPONSE_TYPE_FILE = 2,
	RESPONSE_TYPE_REDIRECT = 3,
};

var _response_type : int = 0
var _status_code : int = HTTPServerEnums.HTTP_STATUS_CODE_200_OK
var _sent_message : String = ""
var _error_handler_called : bool = false
var _parser_path : String = "/"

func _send_redirect(location: String, status_code: int) -> void:
	_response_type = ResponseType.RESPONSE_TYPE_REDIRECT;
	_status_code = status_code;
	_sent_message = location;
	
func _send() -> void:
	_response_type = ResponseType.RESPONSE_TYPE_NORMAL;
	_sent_message = get_compiled_body();

func _send_file(p_file_path: String) -> void:
	_response_type = ResponseType.RESPONSE_TYPE_FILE;
	_sent_message = p_file_path;
	
func _send_error(error_code: int) -> void:
	_error_handler_called = true;
	
	get_server().get_web_root().handle_error_send_request(self, error_code);
	
func _parser_get_path() -> String:
	return _parser_path

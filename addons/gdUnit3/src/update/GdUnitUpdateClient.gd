tool
class_name GdUnitUpdateClient
extends Node

signal request_completed(response)

class HttpResponse:
	var _code :int
	var _body :PoolByteArray

	func _init(code :int, body :PoolByteArray) -> void:
		_code = code
		_body = body

	func code() -> int:
		return _code

	func response():
		return parse_json(_body.get_string_from_utf8())

	func body():
		return _body

var _http_request :HTTPRequest = HTTPRequest.new()

func _ready():
	add_child(_http_request)
	_http_request.connect("request_completed", self, "_on_request_completed")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_http_request):
			_http_request.queue_free()

#func list_tags() -> void:
#	_http_request.connect("request_completed", self, "_response_request_tags")
#	var error = _http_request.request("https://api.github.com/repos/MikeSchulze/gdUnit3/tags")
#	if error != OK:
#		push_error("An error occurred in the HTTP request.")

func request_latest_version() -> HttpResponse:
	yield(get_tree(), "idle_frame")
	var error = _http_request.request("https://api.github.com/repos/MikeSchulze/gdUnit3/tags")
	if error != OK:
		var message = "request_latest_version failed: %d" % error
		return HttpResponse.new(error, message.to_utf8())
	return yield(self, "request_completed")

func request_releases() -> HttpResponse:
	yield(get_tree(), "idle_frame")
	var error = _http_request.request("https://api.github.com/repos/MikeSchulze/gdUnit3/releases")
	if error != OK:
		var message = "request_releases failed: %d" % error
		return HttpResponse.new(error, message.to_utf8())
	return yield(self, "request_completed")

func request_image(url :String) -> HttpResponse:
	yield(get_tree(), "idle_frame")
	var error = _http_request.request(url)
	if error != OK:
		var message = "request_image failed: %d" % error
		return HttpResponse.new(error, message.to_utf8())
	return yield(self, "request_completed")

func request_zip_package(url :String, file :String) -> HttpResponse:
	yield(get_tree(), "idle_frame")
	_http_request.set_download_file(file)
	var error = _http_request.request(url)
	if error != OK:
		var message = "request_zip_package failed: %d" % error
		return HttpResponse.new(error, message.to_utf8())
	return yield(self, "request_completed")

func _on_request_completed(result :int, response_code :int, headers :PoolStringArray, body :PoolByteArray):
	if _http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_request.set_download_file("")
	emit_signal("request_completed", HttpResponse.new(response_code, body))

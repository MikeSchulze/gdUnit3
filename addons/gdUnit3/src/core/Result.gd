class_name Result
extends Reference

enum {
	SUCCESS,
	WARN,
	ERROR,
	EMPTY
}

var _state
var _warn_message := ""
var _error_message := ""
var _value = null

static func __instance() -> Result:
	return load("res://addons/gdUnit3/src/core/Result.gd").new()

static func success(value) -> Result:
	assert(value != null, "The value must not be NULL")
	var result := __instance()
	result._value = value
	result._state = SUCCESS
	return result

static func warn(warn_message :String, value = null) -> Result:
	assert(not warn_message.empty(), "The message must not be empty")
	var result := __instance()
	result._value = value
	result._warn_message = warn_message
	result._state = WARN
	return result

static func error(error_message :String, error :int = 0) -> Result:
	assert(not error_message.empty(), "The message must not be empty")
	var result := __instance()
	result._value = null
	result._error_message = error_message
	result._state = ERROR
	return result

static func empty() -> Result:
	var result := __instance()
	result._state = EMPTY
	return result


func is_success() -> bool:
	return _state == SUCCESS

func is_warn() -> bool:
	return _state == WARN

func is_error() -> bool:
	return _state == ERROR

func is_empty() -> bool:
	return _state == EMPTY

func value():
	return _value
	
func or_else(value):
	if not is_success():
		return value
	return value()

func error_message() -> String:
	return _error_message

func warn_message() -> String:
	return _warn_message
	
func _to_string() -> String:
	return str(serialize(self))

static func serialize(result :Result) -> Dictionary:
	if result == null:
		push_error("Can't serialize a Null object from type Result")
	return {
		"state" : result._state,
		"value" : var2str(result._value),
		"warn_msg" : result._warn_message,
		"err_msg" : result._error_message
	}

static func deserialize(config :Dictionary) -> Result:
	var result := __instance()
	result._value = str2var(config.get("value", ""))
	result._warn_message = config.get("warn_msg", null)
	result._error_message = config.get("err_msg", null)
	result._state = config.get("state")
	return result


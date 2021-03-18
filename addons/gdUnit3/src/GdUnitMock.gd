class_name GdUnitMock
extends Reference

# do call the real implementation
const CALL_REAL_FUNC = "CALL_REAL_FUNC"
# do return a default value for primitive types or null 
const RETURN_DEFAULTS = "RETURN_DEFAULTS"
# do return a default value for primitive types and a fully mocked value for Object types
# builds full deep mocked object
const RETURN_DEEP_STUB = "RETURN_DEEP_STUB"

var _value
	
func _init(value):
	_value = value

func on(mock :Object):
	if mock is GDScript and not mock.get_script().has_script_method("__do_return"):
		push_error("Error: You try to manipulate a non mocked object.")
		return null
	return mock.__do_return(_value)

static func verify(mock :Object, times):
	return mock.__do_verify(times)

static func verify_no_interactions(mock :Object):
	mock.__verify_no_interactions()

static func reset(mock :Object) -> void:
	if mock is GDScript and not mock.get_script().has_script_method("__reset"):
		push_error("Error: You try to reset a non mocked object.")
		return
	mock.__reset()

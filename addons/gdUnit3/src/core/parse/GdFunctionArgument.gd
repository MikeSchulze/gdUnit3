class_name GdFunctionArgument
extends Reference

var _name: String
var _type: String
var _default_value

const UNDEFINED = "<-NO_ARG->"
const ARG_PARAMETERIZED_TEST = "test_parameters"

func _init(name :String, type :String ="", default_value = UNDEFINED):
	_name = name
	_type = type
	_default_value = default_value

func name() -> String:
	return _name

func default():
	return _default_value

func type() -> String:
	return _type

func is_parameter_set() -> bool:
	return _name == ARG_PARAMETERIZED_TEST

static func get_parameter_set(parameters :Array) -> GdFunctionArgument:
	for current in parameters:
		if current != null and current.is_parameter_set():
			return current
	return null

func _to_string() -> String:
	var s = _name
	if not _type.empty():
		s += ":" + _type
	if _default_value != UNDEFINED:
		s += "=" + str(_default_value)
	return s

class_name GdFunctionArgument
extends Reference

var _name: String
var _type: String
var _default_value :String

func _init(name :String, type :String ="", default_value :String =""):
	_name = name
	_type = type
	_default_value = default_value

func name() -> String:
	return _name

func default() -> String:
	return _default_value

func _to_string() -> String:
	var s = _name
	if not _type.empty():
		s += ":" + _type
	if not _default_value.empty():
		s += "=" + _default_value
	return s

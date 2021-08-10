class_name GdUnitProperty
extends Reference

var _name :String
var _help :String
var _type :int
var _value
var _default

func _init(name :String, type :int, value, default_value, help :="" ):
	_name = name
	_type = type
	_value = value
	_default = default_value
	_help = help

func name() -> String:
	return _name

func type() -> int:
	return _type

func value():
	return _value

func set_value(value) -> void:
	match _type:
		TYPE_STRING:
			_value = str(value)
		TYPE_BOOL:
			_value = bool(value)
		TYPE_INT:
			_value = int(value)
		TYPE_REAL:
			_value = float(value)

func default():
	return _default

func category() -> String:
	var elements := _name.split("/")
	if elements.size() > 3:
		return elements[2]
	return ""

func help() -> String:
	return _help

func _to_string() -> String:
	return "%-64s %-10s %-10s (%s) help:%s" % [name(), GdObjects.type_as_string(type()), value(), default(), help()]

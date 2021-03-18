class_name CmdCommand
extends Reference

var _name :String
var _arguments :PoolStringArray

func _init(name :String, arguments := PoolStringArray()):
	_name = name
	_arguments = arguments

func name() -> String:
	return _name

func arguments() -> PoolStringArray:
	return _arguments

func add_argument(arg :String) -> void:
	_arguments.append(arg)

func _to_string():
	return "%s:%s" % [_name, _arguments.join(", ")]

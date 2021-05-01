# This class defines a value extractor by given name and args
class_name GdUnitValueExtractor
extends Reference

var _func_name :String
var _args :Array

func _init(func_name :String, args :Array):
	_func_name = func_name
	_args = args

func func_name() -> String:
	return _func_name

func args() -> Array:
	return _args

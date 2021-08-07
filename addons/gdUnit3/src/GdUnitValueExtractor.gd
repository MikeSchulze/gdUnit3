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

# extracts a value by given `func_name` and `args`,
# if the value not a Object or not accesible be `func_name` the value is converted to `"n.a."`
# expecing null values
func extract_value(value):
	if value == null:
		return null
	
	# for array types we need to call explicit by function name, using funcref is only supported for Objects
	# TODO extend to all array functions
	if GdObjects.is_array_type(value) and func_name() == "empty":
		return value.empty()
	
	if not (value is Object):
		if GdUnitSettings.is_verbose_assert_warnings():
			push_warning("Extracting value from element '%s' by func '%s' failed! Converting to \"n.a.\"" % [value, func_name()])
		return "n.a."
	var extract := funcref(value, func_name())
	if extract.is_valid():
		return value.call(func_name()) if args().empty() else value.callv(func_name(), args())
	else:
		if GdUnitSettings.is_verbose_assert_warnings():
			push_warning("Extracting value from element '%s' by func '%s' failed! Converting to \"n.a.\"" % [value, func_name()])
		return "n.a."

class_name GdFunctionDescriptor
extends Reference

# https://github.com/godotengine/godot/issues/47449
const METHOD_FLAG_VARARG = 128

var _is_virtual :bool
var _is_static :bool
var _is_engine :bool
var _name :String
var _return_type :int
var _return_class :String
var _args : Array
var _varargs :Array

func _init(name :String, is_virtual :bool, is_static :bool, is_engine :bool, return_type :int, return_class :String, args : Array, varargs :Array = []):
	_name = name
	_return_type = return_type
	_return_class = return_class
	_is_virtual = is_virtual
	_is_static = is_static
	_is_engine = is_engine
	_args = args
	_varargs = varargs

static func of(name :String, is_virtual :bool, is_static :bool, is_engine :bool, return_type :int, return_class :String, args :Array, varargs :Array) -> GdFunctionDescriptor:
	return load("res://addons/gdUnit3/src/core/parse/GdFunctionDescriptor.gd").new(
		name,
		is_virtual,
		is_static,
		is_engine,
		return_type,
		return_class,
		args,
		varargs
	)

func name() -> String:
	return _name

func is_virtual() -> bool:
	return _is_virtual

func is_static() -> bool:
	return _is_static

func is_engine() -> bool:
	return _is_engine

func is_vararg() -> bool:
	return not _varargs.empty()

func return_type() -> int:
	return _return_type
	
func return_type_as_string() -> String:
	if return_type() == TYPE_OBJECT and not _return_class.empty():
		return _return_class
	return GdObjects.type_as_string(return_type())

func args() -> Array:
	return _args

func varargs() -> Array:
	return _varargs

func typeless() -> String:
	var func_signature := ""
	if _return_type == TYPE_NIL:
		func_signature = "func %s(%s):" % [name(), typeless_args()]
	else:
		func_signature = "func %s(%s) -> %s:" % [name(), typeless_args(), return_type_as_string()]
	return "static " + func_signature if is_static() else func_signature

func typeless_args() -> String:
	var collect := PoolStringArray()
	for arg in args():
		if not arg.default().empty():
			collect.push_back(arg.name() + "=" + arg.default())
		else:
			collect.push_back(arg.name())
	for arg in varargs():
		collect.push_back(arg.name() + "=" + arg.default())
	return collect.join(", ")

func typed_args() -> String:
	var collect := PoolStringArray()
	for arg in args():
		collect.push_back(arg._to_string())
	for arg in varargs():
		collect.push_back(arg._to_string())
	return collect.join(", ")

func _to_string() -> String:
	var fsignature := "virtual " if is_virtual() else ""
	if _return_type == TYPE_NIL:
		return fsignature + "func %s(%s):" % [name(), typed_args()]
	var func_template := fsignature + "func %s(%s) -> %s:"
	if is_static():
		func_template= "static func %s(%s) -> %s:"
	return func_template % [name(), typed_args(), return_type_as_string()]

# extract function description given by Object.get_method_list()
static func extract_from(method_descriptor :Dictionary) -> GdFunctionDescriptor:
	var is_virtual :bool = method_descriptor["flags"] & METHOD_FLAG_VIRTUAL
	var is_vararg :bool = method_descriptor["flags"] & METHOD_FLAG_VARARG
	return of(
		method_descriptor["name"],
		is_virtual,
		false,
		true,
		method_descriptor["return"]["type"],
		method_descriptor["return"]["class_name"],
		_extract_args(method_descriptor),
		_build_varargs(is_vararg)
	)

static func _extract_args(method_descriptor :Dictionary) -> Array:
	var args := Array()
	var arguments :Array = method_descriptor["args"]
	var defaults :Array = method_descriptor["default_args"]
	# iterate backwards because the default values are stored from right to left
	while not arguments.empty():
		var arg :Dictionary = arguments.pop_back()
		var arg_name := _argument_name(arg)
		var arg_type := _argument_type_as_string(arg)
		var arg_default :String = ""
		if not defaults.empty():
			arg_default = _argument_default_value(arg, defaults.pop_back())
		args.push_front(GdFunctionArgument.new(arg_name, arg_type, arg_default))
	return args

static func _build_varargs(is_vararg :bool) -> Array:
	var varargs := Array()
	if not is_vararg:
		return varargs
	# if function has vararg we need to handle this manually by adding 10 default arguments
	var type := GdObjects.type_as_string(GdObjects.TYPE_VARARG)
	for index in 10:
		varargs.push_back(GdFunctionArgument.new("vararg%d_" % index, type, "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE))
	return varargs

static func _argument_name(arg :Dictionary) -> String:
	# add suffix to the name to prevent clash with reserved names
	return (arg["name"] + "_") as String

static func _argument_type(arg :Dictionary) -> int:
	return arg["type"] as int

static func _argument_type_as_string(arg :Dictionary) -> String:
	var type := _argument_type(arg)
	match type:
		TYPE_NIL:
			return ""
		TYPE_OBJECT:
			var clazz_name :String = arg["class_name"]
			if not clazz_name.empty():
				return clazz_name
			return ""
		_:
			return GdObjects.type_as_string(type)

static func _argument_default_value(arg :Dictionary, default_value) -> String:
	var type := _argument_type(arg)
	match type:
		TYPE_NIL:
			return "null"
		TYPE_STRING:
			return "\"%s\"" % default_value
		TYPE_BOOL:
			# we need to convert to lower case
			return str(default_value).to_lower()
		TYPE_TRANSFORM2D:
			var transform := default_value as Transform2D
			return "Transform2D(Vector2%s, Vector2%s, Vector2%s)" % [transform.x, transform.y, transform.origin]
		TYPE_COLOR_ARRAY:
			var array := default_value as PoolColorArray
			if array.empty():
				return "[]"
			else:
				push_error("TODO, implemnt compile array values")
				return "invalid"
		TYPE_OBJECT:
			var clazz_name := arg["class_name"] as String
			if default_value == null:
				return "null"

	if GdObjects.is_primitive_type(default_value):
		return str(default_value)
	if GdObjects.is_type_array(type):
		if default_value == null:
			return "[]"
		return str(default_value)
	return "%s(%s)" % [GdObjects.type_as_string(type), str(default_value).trim_prefix("(").trim_suffix(")")]

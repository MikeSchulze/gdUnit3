class_name GdFunctionDoubler
extends Reference

const DEFAULT_TYPED_RETURN_VALUES := {
	TYPE_NIL: "null",
	TYPE_BOOL: "false",
	TYPE_INT: "0",
	TYPE_REAL: "0.0",
	TYPE_STRING: "\"\"",
	TYPE_VECTOR2: "Vector2.ZERO",
	TYPE_RECT2: "Rect2()",
	TYPE_VECTOR3: "Vector3.ZERO",
	TYPE_TRANSFORM2D: "Transform2D()",
	TYPE_PLANE: "Plane()",
	TYPE_QUAT: "Quat()",
	TYPE_AABB: "AABB()",
	TYPE_BASIS: "Basis()",
	TYPE_TRANSFORM: "Transform()",
	TYPE_COLOR: "Color()",
	TYPE_NODE_PATH: "NodePath()",
	TYPE_RID: "RID()",
	TYPE_OBJECT: "null",
	TYPE_DICTIONARY: "Dictionary()",
	TYPE_ARRAY: "Array()",
	TYPE_RAW_ARRAY: "PoolByteArray()",
	TYPE_INT_ARRAY: "PoolIntArray()",
	TYPE_REAL_ARRAY: "PoolRealArray()",
	TYPE_STRING_ARRAY: "PoolStringArray()",
	TYPE_VECTOR2_ARRAY: "PoolVector2Array()",
	TYPE_VECTOR3_ARRAY: "PoolVector3Array()",
	TYPE_COLOR_ARRAY: "PoolColorArray()",
}

static func return_value(type :int) -> String:
	if DEFAULT_TYPED_RETURN_VALUES.has(type):
		return DEFAULT_TYPED_RETURN_VALUES.get(type)
	return "void"

func double(func_descriptor :GdFunctionDescriptor) -> PoolStringArray:
	push_error("FunctionDoubler#double() is not implemented!")
	return PoolStringArray()

func extract_arg_names(argument_signatures :Array) -> PoolStringArray:
	var arg_names := PoolStringArray()
	for arg in argument_signatures:
		arg_names.append(arg._name)
	return arg_names

static func extract_constructor_args(args :Array) -> PoolStringArray:
	var constructor_args := PoolStringArray()
	for arg in args:
		var a := arg as GdFunctionArgument
		var arg_name := a._name
		var default_value = get_default(a)
		constructor_args.append(arg_name + "=" + default_value)
	return constructor_args

static func get_default(arg :GdFunctionArgument):
	if arg.default():
		return arg.default()
	else:
		var arg_type := GdObjects.string_to_type(arg._type)
		return return_value(arg_type)

# GdUnit generated TestSuite
class_name GdUnitSpyBuilderTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/spy/GdUnitSpyBuilder.gd'

# helper to get function descriptor
static func get_function_description(clazz_name :String, method_name :String) -> GdFunctionDescriptor:
	var method_list :Array = ClassDB.class_get_method_list(clazz_name)
	for method_descriptor in method_list:
		if method_descriptor["name"] == method_name:
			return GdFunctionDescriptor.extract_from(method_descriptor)
	return null

func test_double_return_typed_function_without_arg() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	# String get_class() const
	var fd := get_function_description("Object", "get_class")
	assert_array(doubler.double(fd)).contains_exactly([
		"func get_class() -> String:",
		"	var args :Array = [\"get_class\"] + []",
		"	",
		"	if __is_verify_interactions():",
		"		return __verify_interactions(args)",
		"	else:",
		"		__save_function_interaction(args)",
		"	if false == false:",
		"		return .get_class()",
		"	return \"\"",
		""])

func test_double_return_typed_function_with_args() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	# bool is_connected(signal: String, target: Object, method: String) const
	var fd := get_function_description("Object", "is_connected")
	assert_array(doubler.double(fd)).contains_exactly([
		"func is_connected(signal_, target_, method_) -> bool:",
		"	var args :Array = [\"is_connected\"] + [signal_, target_, method_]",
		"	",
		"	if __is_verify_interactions():",
		"		return __verify_interactions(args)",
		"	else:",
		"		__save_function_interaction(args)",
		"	if false == false:",
		"		return .is_connected(signal_, target_, method_)",
		"	return false",
		""])

func test_double_return_undef_function_with_args() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	# void disconnect(signal: String, target: Object, method: String)
	var fd := get_function_description("Object", "disconnect")
	assert_array(doubler.double(fd)).contains_exactly([
		"func disconnect(signal_, target_, method_):",
		"	var args :Array = [\"disconnect\"] + [signal_, target_, method_]",
		"	",
		"	if __is_verify_interactions():",
		"		return __verify_interactions(args)",
		"	else:",
		"		__save_function_interaction(args)",
		"	if false == false:",
		"		return .disconnect(signal_, target_, method_)",
		"	return null",
		""])

func test_double_void_function_with_args_and_varargs() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	# void emit_signal(signal: String, ...) vararg
	var fd := get_function_description("Object", "emit_signal")
	assert_array(doubler.double(fd)).contains_exactly([
		"func emit_signal(signal_, vararg0_=\"__null__\", vararg1_=\"__null__\", vararg2_=\"__null__\", vararg3_=\"__null__\", vararg4_=\"__null__\", vararg5_=\"__null__\", vararg6_=\"__null__\", vararg7_=\"__null__\", vararg8_=\"__null__\", vararg9_=\"__null__\"):",
		"	var varargs :Array = __filter_vargs([vararg0_, vararg1_, vararg2_, vararg3_, vararg4_, vararg5_, vararg6_, vararg7_, vararg8_, vararg9_])",
		"	var args :Array = [\"emit_signal\"] + [signal_] + varargs",
		"	",
		"	if __is_verify_interactions():",
		"		__verify_interactions(args)",
		"		return",
		"	else:",
		"		__save_function_interaction(args)",
		"	",
		"	if false == false:",
		"		match varargs.size():",
		"			0: .emit_signal(signal_)",
		"			1: .emit_signal(signal_, varargs[0])",
		"			2: .emit_signal(signal_, varargs[0], varargs[1])",
		"			3: .emit_signal(signal_, varargs[0], varargs[1], varargs[2])",
		"			4: .emit_signal(signal_, varargs[0], varargs[1], varargs[2], varargs[3])",
		"			5: .emit_signal(signal_, varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])",
		"			6: .emit_signal(signal_, varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])",
		"			7: .emit_signal(signal_, varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])",
		"			8: .emit_signal(signal_, varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])",
		"			9: .emit_signal(signal_, varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])",
		"			10: .emit_signal(signal_, varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])",
		""])


func test_double_void_function_without_args_and_varargs() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	# void VisualScriptFunctionState:_signal_callback(s...) vararg
	var fd := get_function_description("VisualScriptFunctionState", "_signal_callback")
	assert_array(doubler.double(fd)).contains_exactly([
		"func _signal_callback(vararg0_=\"__null__\", vararg1_=\"__null__\", vararg2_=\"__null__\", vararg3_=\"__null__\", vararg4_=\"__null__\", vararg5_=\"__null__\", vararg6_=\"__null__\", vararg7_=\"__null__\", vararg8_=\"__null__\", vararg9_=\"__null__\"):",
		"	var varargs :Array = __filter_vargs([vararg0_, vararg1_, vararg2_, vararg3_, vararg4_, vararg5_, vararg6_, vararg7_, vararg8_, vararg9_])",
		"	var args :Array = [\"_signal_callback\"] + varargs",
		"	",
		"	if __is_verify_interactions():",
		"		__verify_interactions(args)",
		"		return",
		"	else:",
		"		__save_function_interaction(args)",
		"	",
		"	if false == false:",
		"		match varargs.size():",
		"			0: ._signal_callback()",
		"			1: ._signal_callback(varargs[0])",
		"			2: ._signal_callback(varargs[0], varargs[1])",
		"			3: ._signal_callback(varargs[0], varargs[1], varargs[2])",
		"			4: ._signal_callback(varargs[0], varargs[1], varargs[2], varargs[3])",
		"			5: ._signal_callback(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])",
		"			6: ._signal_callback(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])",
		"			7: ._signal_callback(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])",
		"			8: ._signal_callback(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])",
		"			9: ._signal_callback(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])",
		"			10: ._signal_callback(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])",
		""])

func test_double_static_script_function_no_args() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	var fd := GdFunctionDescriptor.new( "foo", false, true, false, TYPE_NIL, "", [])
	assert_array(doubler.double(fd)).contains_exactly([
		"static func foo():",
		"	var args :Array = [\"foo\"] + []",
		"	",
		"	if __self[0].__is_verify_interactions():",
		"		return __self[0].__verify_interactions(args)",
		"	else:",
		"		__self[0].__save_function_interaction(args)",
		"	if false == false:",
		"		return .foo()",
		"	return null",
		""])

func test_double_static_script_function_with_args() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	var fd := GdFunctionDescriptor.new( "foo", false, true, false, TYPE_NIL, "", [
		GdFunctionArgument.new("arg1", "bool", ""),
		GdFunctionArgument.new("arg2", "String", "\"default\"")
	])
	assert_array(doubler.double(fd)).contains_exactly([
		"static func foo(arg1, arg2=\"default\"):",
		"	var args :Array = [\"foo\"] + [arg1, arg2]",
		"	",
		"	if __self[0].__is_verify_interactions():",
		"		return __self[0].__verify_interactions(args)",
		"	else:",
		"		__self[0].__save_function_interaction(args)",
		"	if false == false:",
		"		return .foo(arg1, arg2)",
		"	return null",
		""])

func test_double_script_function_no_args() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	var fd := GdFunctionDescriptor.new( "foo", false, false, false, TYPE_NIL, "", [])
	assert_array(doubler.double(fd)).contains_exactly([
		"func foo():",
		"	var args :Array = [\"foo\"] + []",
		"	",
		"	if __is_verify_interactions():",
		"		return __verify_interactions(args)",
		"	else:",
		"		__save_function_interaction(args)",
		"	if false == false:",
		"		return .foo()",
		"	return null",
		""])

func test_double_script_function_with_args() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	var fd := GdFunctionDescriptor.new( "foo", false, false, false, TYPE_NIL, "", [
		GdFunctionArgument.new("arg1", "bool", ""),
		GdFunctionArgument.new("arg2", "String", "\"default\"")
	])
	assert_array(doubler.double(fd)).contains_exactly([
		"func foo(arg1, arg2=\"default\"):",
		"	var args :Array = [\"foo\"] + [arg1, arg2]",
		"	",
		"	if __is_verify_interactions():",
		"		return __verify_interactions(args)",
		"	else:",
		"		__save_function_interaction(args)",
		"	if false == false:",
		"		return .foo(arg1, arg2)",
		"	return null",
		""])

func test_double_virtual_script_function_with_arg() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	# void _input(event: InputEvent) virtual
	var fd := get_function_description("Node", "_input")
	assert_array(doubler.double(fd)).contains_exactly([
		"func _input(event_):",
		"	var args :Array = [\"_input\"] + [event_]",
		"	",
		"	if __is_verify_interactions():",
		"		return __verify_interactions(args)",
		"	else:",
		"		__save_function_interaction(args)",
		"	if true == false:",
		"		return ._input(event_)",
		"	return null",
		""])

func test_double_virtual_script_function_without_arg() -> void:
	var doubler := GdUnitSpyBuilder.SpyFunctionDoubler.new()
	
	# void _ready() virtual
	var fd := get_function_description("Node", "_ready")
	assert_array(doubler.double(fd)).contains_exactly([
		"func _ready():",
		"	var args :Array = [\"_ready\"] + []",
		"	",
		"	if __is_verify_interactions():",
		"		return __verify_interactions(args)",
		"	else:",
		"		__save_function_interaction(args)",
		"	if true == false:",
		"		return ._ready()",
		"	return null",
		""])

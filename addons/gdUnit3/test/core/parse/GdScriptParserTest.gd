extends GdUnitTestSuite

var _parser: GdScriptParser

func before():
	_parser = GdScriptParser.new()

func test_parse_argument():
	# create example row whit different assignment types
	var row = "func test_foo(arg1 = 41, arg2 := 42, arg3 : int = 43)"
	assert_that(_parser.parse_argument(row, "arg1", 23)).is_equal(41)
	assert_that(_parser.parse_argument(row, "arg2", 23)).is_equal(42)
	assert_that(_parser.parse_argument(row, "arg3", 23)).is_equal(43)


func test_parse_argument_GD_376():
	# parse constructor with a argument named with prefix `function`
	var row = "func _init(function_enum = 42)"
	assert_that(_parser.parse_argument(row, "function_enum", 42)).is_equal(42)


func test_parse_argument_default_value():
	# arg4 not exists expect to return the default value
	var row = "func test_foo(arg1 = 41, arg2 := 42, arg3 : int = 43)"
	assert_that(_parser.parse_argument(row, "arg4", 23)).is_equal(23)

func test_parse_argument_has_no_arguments():
	assert_that(_parser.parse_argument("func test_foo()", "arg4", 23)).is_equal(23)
	
func test_parse_argument_with_bad_formatting():
	var row = "func test_foo(	arg1 =   41, arg2 :	 = 42, arg3 	: int 	=    43  )"
	assert_that(_parser.parse_argument(row, "arg3", 23)).is_equal(43)

func test_parse_argument_with_same_func_name():
	var row = "func test_arg1(arg1 = 41)"
	assert_that(_parser.parse_argument(row, "arg1", 23)).is_equal(41)

func test_parse_argument_timeout():
	var DEFAULT_TIMEOUT = 1000
	assert_that(_parser.parse_argument("func test_foo()", "timeout", DEFAULT_TIMEOUT)).is_equal(DEFAULT_TIMEOUT)
	assert_that(_parser.parse_argument("func test_foo(timeout = 2000)", "timeout", DEFAULT_TIMEOUT)).is_equal(2000)
	assert_that(_parser.parse_argument("func test_foo(timeout: = 2000)", "timeout", DEFAULT_TIMEOUT)).is_equal(2000)
	assert_that(_parser.parse_argument("func test_foo(timeout:int = 2000)", "timeout", DEFAULT_TIMEOUT)).is_equal(2000)
	assert_that(_parser.parse_argument("func test_foo(arg1 = false, timeout=2000)", "timeout", DEFAULT_TIMEOUT)).is_equal(2000)

func test_parse_arguments():
	assert_array(_parser.parse_arguments("func foo():")) \
		.has_size(0)
	
	assert_array(_parser.parse_arguments("func foo() -> String:\n")) \
		.has_size(0)
	
	assert_array(_parser.parse_arguments("func foo(arg1, arg2, name):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1"), 
			GdFunctionArgument.new("arg2"),
			GdFunctionArgument.new("name")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :int, arg2 :bool, name :String = \"abc\"):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "int"), 
			GdFunctionArgument.new("arg2", "bool"),
			GdFunctionArgument.new("name", "String", "\"abc\"")])
	
	assert_array(_parser.parse_arguments("func bar(arg1 :int, arg2 :int = 23, name :String = \"test\") -> String:")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "int"),
			GdFunctionArgument.new("arg2", "int", "23"),
			GdFunctionArgument.new("name", "String", "\"test\"")])
	
	assert_array(_parser.parse_arguments("func foo(arg1, arg2=value(1,2,3), name:=foo()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1"), 
			GdFunctionArgument.new("arg2", "Func", "value(1,2,3)"),
			GdFunctionArgument.new("name", "Func", "foo()")])
	# enum as prefix in value name
	assert_array(_parser.parse_arguments("func get_value( type := ENUM_A) -> int:"))\
		.contains_exactly([GdFunctionArgument.new("type", "String", "ENUM_A")])
	
	assert_array(_parser.parse_arguments("func create_timer(timeout :float) -> Timer:")) \
		.contains_exactly([
			GdFunctionArgument.new("timeout", "float")])
	
	# array argument
	assert_array(_parser.parse_arguments("func foo(a :int, b :int, parameters = [[1, 2], [3, 4], [5, 6]]):")) \
		.contains_exactly([
			GdFunctionArgument.new("a", "int"),
			GdFunctionArgument.new("b", "int"),
			GdFunctionArgument.new("parameters", "Array", "[[1, 2], [3, 4], [5, 6]]")])
	
	assert_array(_parser.parse_arguments("func test_values(a:Vector2, b:Vector2, expected:Vector2, test_parameters:=[[Vector2.ONE,Vector2.ONE,Vector2(1,1)]]):"))\
		.contains_exactly([
			GdFunctionArgument.new("a", "Vector2"),
			GdFunctionArgument.new("b", "Vector2"),
			GdFunctionArgument.new("expected", "Vector2"),
			GdFunctionArgument.new("test_parameters", "Array", "[[Vector2.ONE,Vector2.ONE,Vector2(1,1)]]"),
		])

func test_parse_arguments_with_super_constructor():
	assert_array(_parser.parse_arguments('func foo().foo("abc"):')).is_empty()
	assert_array(_parser.parse_arguments('func foo(arg1 = "arg").foo("abc", arg1):'))\
		.contains_exactly([GdFunctionArgument.new("arg1", "String", '"arg"')])

func test_parse_arguments_default_build_in_type_String():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=\"default\"):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "String", "\"default\"")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=\"default\"):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "String", "\"default\"")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :String =\"default\"):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "String", "\"default\"")])

func test_parse_arguments_default_build_in_type_Boolean():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "bool", "false")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "bool", "false")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :bool=false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "bool", "false")])

func test_parse_arguments_default_build_in_type_Real():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=3.14):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "float", "3.14")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=3.14):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "float", "3.14")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :float=3.14):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "float", "3.14")])

func test_parse_arguments_default_build_in_type_Array():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :Array=[]):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Array", "[]")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :Array=Array()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Array", "Array()")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :Array=[1, 2, 3]):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Array", "[1, 2, 3]")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=[1, 2, 3]):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Array", "[1, 2, 3]")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=[]):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Array", "[]")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :Array=[1, 2, 3], arg3 := false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Array", "[1, 2, 3]"),
			GdFunctionArgument.new("arg3", "bool", "false")])

func test_parse_arguments_default_build_in_type_Color():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=Color.red):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Color", "Color.red")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=Color.red):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Color", "Color.red")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :Color=Color.red):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Color", "Color.red")])

func test_parse_arguments_default_build_in_type_Vector():
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 =Vector3.FORWARD):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Vector3", "Vector3.FORWARD")])
	
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 :=Vector3.FORWARD):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Vector3", "Vector3.FORWARD")])
	
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 :Vector3=Vector3.FORWARD):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Vector3", "Vector3.FORWARD")])

func test_parse_arguments_default_build_in_type_AABB():
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 := AABB()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "AABB", "AABB()")])
	
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 :AABB=AABB()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "AABB", "AABB()")])

func test_parse_arguments_default_build_in_types():
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 := Vector3.FORWARD, aabb := AABB()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Vector3", "Vector3.FORWARD"),
			GdFunctionArgument.new("aabb", "AABB", "AABB()")])

func test_parse_arguments_fuzzers() -> void:
	assert_array(_parser.parse_arguments("func test_foo(fuzzer_a = fuzz_a(), fuzzer_b := fuzz_b(), fuzzer_c :Fuzzer = fuzz_c(), fuzzer_iterations = 234, fuzzer_seed = 100):")) \
		.contains_exactly([
			GdFunctionArgument.new("fuzzer_a", "Fuzzer", "fuzz_a()"),
			GdFunctionArgument.new("fuzzer_b", "Fuzzer", "fuzz_b()"),
			GdFunctionArgument.new("fuzzer_c", "Fuzzer", "fuzz_c()"),
			GdFunctionArgument.new("fuzzer_iterations", "int", "234"),
			GdFunctionArgument.new("fuzzer_seed", "int", "100"),])

func test_parse_arguments_no_function():
	assert_array(_parser.parse_arguments("var x:=10")) \
		.has_size(0)

class TestObject:
	var x

func test_parse_function_return_type():
	assert_that(_parser.parse_func_return_type("func foo():")).is_equal(TYPE_NIL)
	assert_that(_parser.parse_func_return_type("func foo() -> void:")).is_equal(GdObjects.TYPE_VOID)
	assert_that(_parser.parse_func_return_type("func foo() -> TestObject:")).is_equal(TYPE_OBJECT)
	assert_that(_parser.parse_func_return_type("func foo() -> bool:")).is_equal(TYPE_BOOL)
	assert_that(_parser.parse_func_return_type("func foo() -> String:")).is_equal(TYPE_STRING)
	assert_that(_parser.parse_func_return_type("func foo() -> int:")).is_equal(TYPE_INT)
	assert_that(_parser.parse_func_return_type("func foo() -> float:")).is_equal(TYPE_REAL)
	assert_that(_parser.parse_func_return_type("func foo() -> Vector2:")).is_equal(TYPE_VECTOR2)
	assert_that(_parser.parse_func_return_type("func foo() -> Rect2:")).is_equal(TYPE_RECT2)
	assert_that(_parser.parse_func_return_type("func foo() -> Vector3:")).is_equal(TYPE_VECTOR3)
	assert_that(_parser.parse_func_return_type("func foo() -> Transform2D:")).is_equal(TYPE_TRANSFORM2D)
	assert_that(_parser.parse_func_return_type("func foo() -> Plane:")).is_equal(TYPE_PLANE)
	assert_that(_parser.parse_func_return_type("func foo() -> Quat:")).is_equal(TYPE_QUAT)
	assert_that(_parser.parse_func_return_type("func foo() -> AABB:")).is_equal(TYPE_AABB)
	assert_that(_parser.parse_func_return_type("func foo() -> Basis:")).is_equal(TYPE_BASIS)
	assert_that(_parser.parse_func_return_type("func foo() -> Transform:")).is_equal(TYPE_TRANSFORM)
	assert_that(_parser.parse_func_return_type("func foo() -> Color:")).is_equal(TYPE_COLOR)
	assert_that(_parser.parse_func_return_type("func foo() -> NodePath:")).is_equal(TYPE_NODE_PATH)
	assert_that(_parser.parse_func_return_type("func foo() -> RID:")).is_equal(TYPE_RID)
	assert_that(_parser.parse_func_return_type("func foo() -> Dictionary:")).is_equal(TYPE_DICTIONARY)
	assert_that(_parser.parse_func_return_type("func foo() -> Array:")).is_equal(TYPE_ARRAY)
	assert_that(_parser.parse_func_return_type("func foo() -> PoolByteArray:")).is_equal(TYPE_RAW_ARRAY)
	assert_that(_parser.parse_func_return_type("func foo() -> PoolIntArray:")).is_equal(TYPE_INT_ARRAY)
	assert_that(_parser.parse_func_return_type("func foo() -> PoolRealArray:")).is_equal(TYPE_REAL_ARRAY)
	assert_that(_parser.parse_func_return_type("func foo() -> PoolStringArray:")).is_equal(TYPE_STRING_ARRAY)
	assert_that(_parser.parse_func_return_type("func foo() -> PoolVector2Array:")).is_equal(TYPE_VECTOR2_ARRAY)
	assert_that(_parser.parse_func_return_type("func foo() -> PoolVector3Array:")).is_equal(TYPE_VECTOR3_ARRAY)
	assert_that(_parser.parse_func_return_type("func foo() -> PoolColorArray:")).is_equal(TYPE_COLOR_ARRAY)
	# test with complex function signature
	var signature := 'functest_parameterized_dict_values(data:Dictionary,expected:String,test_parameters:=[[{"key_a":"value_a"},"key_a:value_a"],[{"key_b":"value_b"},"key_b:value_b"]]):'
	assert_that(_parser.parse_func_return_type(signature)).is_equal(TYPE_NIL)

func test_parse_func_name():
	assert_str(_parser.parse_func_name("func foo():")).is_equal("foo")
	assert_str(_parser.parse_func_name("static func foo():")).is_equal("foo")
	assert_str(_parser.parse_func_name("func a() -> String:")).is_equal("a")
	# function name contains tokens e.g func or class
	assert_str(_parser.parse_func_name("func foo_func_class():")).is_equal("foo_func_class")
	# should fail
	assert_str(_parser.parse_func_name("#func foo():")).is_empty()
	assert_str(_parser.parse_func_name("var x")).is_empty()

func test_extract_source_code():
	var path := GdObjects.extract_class_path(AdvancedTestClass)
	var rows = _parser.extract_source_code(path)
	
	var file_content := resource_as_array(path[0])
	assert_array(rows).contains_exactly(file_content)

func test_extract_source_code_inner_class_AtmosphereData():
	var path := GdObjects.extract_class_path(AdvancedTestClass.AtmosphereData)
	var rows = _parser.extract_source_code(path)
	var file_content := resource_as_array("res://addons/gdUnit3/test/core/resources/AtmosphereData.txt")
	assert_array(rows).contains_exactly(file_content)

func test_extract_source_code_inner_class_SoundData():
	var path := GdObjects.extract_class_path(AdvancedTestClass.SoundData)
	var rows = _parser.extract_source_code(path)
	var file_content := resource_as_array("res://addons/gdUnit3/test/core/resources/SoundData.txt")
	assert_array(rows).contains_exactly(file_content)

func test_extract_source_code_inner_class_Area4D():
	var path := GdObjects.extract_class_path(AdvancedTestClass.Area4D)
	var rows = _parser.extract_source_code(path)
	var file_content := resource_as_array("res://addons/gdUnit3/test/core/resources/Area4D.txt")
	assert_array(rows).contains_exactly(file_content)

func test_extract_function_signature() -> void:
	var path := GdObjects.extract_class_path("res://addons/gdUnit3/test/mocker/resources/ClassWithCustomFormattings.gd")
	var rows = _parser.extract_source_code(path)
	
	assert_that(_parser.extract_func_signature(rows, 9))\
		.is_equal('func a1(set_name:String, path:String="", load_on_init:bool=false,set_auto_save:bool=false, set_network_sync:bool=false) -> void:')
	assert_that(_parser.extract_func_signature(rows, 14))\
		.is_equal('func a2(set_name:String, path:String="", load_on_init:bool=false,set_auto_save:bool=false, set_network_sync:bool=false) -> void:')
	assert_that(_parser.extract_func_signature(rows, 19))\
		.is_equal('func a3(set_name:String, path:String="", load_on_init:bool=false,set_auto_save:bool=false, set_network_sync:bool=false) :')
	assert_that(_parser.extract_func_signature(rows, 24))\
		.is_equal('func a4(set_name:String,path:String="",load_on_init:bool=false,set_auto_save:bool=false,set_network_sync:bool=false):')
	assert_that(_parser.extract_func_signature(rows, 32))\
		.is_equal('func a5(value : Array,expected : String,test_parameters : Array = [[ ["a"], "a" ],[ ["a", "very", "long", "argument"], "a very long argument" ],]):')


func test_extract_function_signature_GD_376() -> void:
	var rows = ["func _init(function_enum :int):"]
	assert_that(_parser.extract_func_signature(rows, 0))\
		.is_equal('func _init(function_enum :int):')


func test_strip_leading_spaces():
	assert_str(GdScriptParser.TokenInnerClass._strip_leading_spaces("")).is_empty()
	assert_str(GdScriptParser.TokenInnerClass._strip_leading_spaces(" ")).is_empty()
	assert_str(GdScriptParser.TokenInnerClass._strip_leading_spaces("    ")).is_empty()
	assert_str(GdScriptParser.TokenInnerClass._strip_leading_spaces("	 ")).is_equal("	 ")
	assert_str(GdScriptParser.TokenInnerClass._strip_leading_spaces("var x=")).is_equal("var x=")
	assert_str(GdScriptParser.TokenInnerClass._strip_leading_spaces("class foo")).is_equal("class foo")

func test_extract_clazz_name():
	assert_str(_parser.extract_clazz_name("classSoundData:\n")).is_equal("SoundData")
	assert_str(_parser.extract_clazz_name("classSoundDataextendsNode:\n")).is_equal("SoundData")

func test_is_virtual_func() -> void:
	# on non virtual func
	assert_bool(_parser.is_virtual_func("UnknownClass", [""], "")).is_false()
	assert_bool(_parser.is_virtual_func("Node", [""], "")).is_false()
	assert_bool(_parser.is_virtual_func("Node", [""], "func foo():")).is_false()
	# on virtual func
	assert_bool(_parser.is_virtual_func("Node", [""], "_exit_tree")).is_true()
	assert_bool(_parser.is_virtual_func("Node", [""], "_ready")).is_true()
	assert_bool(_parser.is_virtual_func("Node", [""], "_init")).is_true()

func test_is_static_func():
	assert_bool(_parser.is_static_func("")).is_false()
	assert_bool(_parser.is_static_func("var a=0")).is_false()
	assert_bool(_parser.is_static_func("func foo():")).is_false()
	assert_bool(_parser.is_static_func("func foo() -> void:")).is_false()
	assert_bool(_parser.is_static_func("static func foo():")).is_true()
	assert_bool(_parser.is_static_func("static func foo() -> void:")).is_true()

func test_parse_func_description():
	var fd := _parser.parse_func_description("func foo():", "clazz_name", [""], 10)
	assert_str(fd.name()).is_equal("foo")
	assert_bool(fd.is_static()).is_false()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).is_empty()
	assert_str(fd.typeless()).is_equal("func foo():")
	
	# static function
	fd = _parser.parse_func_description("static func foo(arg1 :int, arg2:=false) -> String:", "clazz_name", [""], 22)
	assert_str(fd.name()).is_equal("foo")
	assert_bool(fd.is_static()).is_true()
	assert_int(fd.return_type()).is_equal(TYPE_STRING)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("arg1", "int"),
		GdFunctionArgument.new("arg2", "bool", "false")
	])
	assert_str(fd.typeless()).is_equal("static func foo(arg1, arg2=false) -> String:")
	
	# static function without return type
	fd = _parser.parse_func_description("static func foo(arg1 :int, arg2:=false):", "clazz_name", [""], 23)
	assert_str(fd.name()).is_equal("foo")
	assert_bool(fd.is_static()).is_true()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("arg1", "int"),
		GdFunctionArgument.new("arg2", "bool", "false")
	])
	assert_str(fd.typeless()).is_equal("static func foo(arg1, arg2=false):")


func test_parse_func_description_GD_376():
	var fd := _parser.parse_func_description("func _init(function_enum :int):", "clazz_name", [""], 10)
	assert_str(fd.name()).is_equal("_init")
	assert_bool(fd.is_static()).is_false()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("function_enum", "int"),
	])
	assert_str(fd.typeless()).is_equal("func _init(function_enum):")

func test_parse_class_inherits():
	var clazz_path := GdObjects.extract_class_path(CustomClassExtendsCustomClass)
	var clazz_name := GdObjects.extract_class_name_from_class_path(clazz_path)
	var result := _parser.parse(clazz_name, clazz_path)
	assert_result(result).is_success()
	
	# verify class extraction
	var clazz_desccriptor :GdClassDescriptor = result.value()
	assert_object(clazz_desccriptor).is_not_null()
	assert_str(clazz_desccriptor.name()).is_equal("CustomClassExtendsCustomClass")
	assert_bool(clazz_desccriptor.is_inner_class()).is_false()
	assert_array(clazz_desccriptor.functions()).contains_exactly([
		GdFunctionDescriptor.new("foo2", 5, false, false, false, TYPE_NIL, "", []),
		GdFunctionDescriptor.new("bar2", 8, false, false, false, TYPE_STRING, "", [])
	])
	
	# extends from CustomResourceTestClass
	clazz_desccriptor = clazz_desccriptor.parent()
	assert_object(clazz_desccriptor).is_not_null()
	assert_str(clazz_desccriptor.name()).is_equal("CustomResourceTestClass")
	assert_bool(clazz_desccriptor.is_inner_class()).is_false()
	assert_array(clazz_desccriptor.functions()).contains_exactly([
		GdFunctionDescriptor.new("foo", 4, false, false, false, TYPE_STRING, "", []),
		GdFunctionDescriptor.new("foo2", 7, false, false, false, TYPE_NIL, "", []),
		GdFunctionDescriptor.new("foo_void", 10, false, false, false, GdObjects.TYPE_VOID, "", []),
		GdFunctionDescriptor.new("bar", 13, false, false, false, TYPE_STRING, "", [
			GdFunctionArgument.new("arg1", "int"),
			GdFunctionArgument.new("arg2", "int", "23"),
			GdFunctionArgument.new("name", "String", "\"test\""),
		]),
		GdFunctionDescriptor.new("foo5", 16, false, false, false, TYPE_NIL, "", []),
	])
	
	# no other class extends
	clazz_desccriptor = clazz_desccriptor.parent()
	assert_object(clazz_desccriptor).is_null()

func test_get_class_name_pascal_case() -> void:
	assert_str(_parser.get_class_name(load("res://addons/gdUnit3/test/core/resources/naming_conventions/PascalCaseWithClassName.gd")))\
		.is_equal("PascalCaseWithClassName")
	assert_str(_parser.get_class_name(load("res://addons/gdUnit3/test/core/resources/naming_conventions/PascalCaseWithoutClassName.gd")))\
		.is_equal("PascalCaseWithoutClassName")

func test_get_class_name_snake_case() -> void:
	assert_str(_parser.get_class_name(load("res://addons/gdUnit3/test/core/resources/naming_conventions/snake_case_with_class_name.gd")))\
		.is_equal("SnakeCaseWithClassName")
	assert_str(_parser.get_class_name(load("res://addons/gdUnit3/test/core/resources/naming_conventions/snake_case_without_class_name.gd")))\
		.is_equal("SnakeCaseWithoutClassName")

func test_is_func_end() -> void:
	assert_bool(_parser.is_func_end("")).is_false()
	assert_bool(_parser.is_func_end("func test_a():")).is_true()
	assert_bool(_parser.is_func_end("func test_a() -> void:")).is_true()
	assert_bool(_parser.is_func_end("func test_a(arg1) :")).is_true()
	assert_bool(_parser.is_func_end("func test_a(arg1 ): ")).is_true()
	assert_bool(_parser.is_func_end("func test_a(arg1 ):	")).is_true()
	assert_bool(_parser.is_func_end("	):")).is_true()
	assert_bool(_parser.is_func_end("		):")).is_true()
	assert_bool(_parser.is_func_end("	-> void:")).is_true()
	assert_bool(_parser.is_func_end("		) -> void :")).is_true()
	assert_bool(_parser.is_func_end("func test_a(arg1, arg2 = {1:2} ):")).is_true()

func test_extract_func_signature_multiline() -> void:
	var source_code = [
	"func test_parameterized(a: int, b :int, c :int, expected :int, parameters = [\n",
	"	[1, 2, 3, 6],\n",
	"	[3, 4, 5, 11],\n",
	"	[6, 7, 8, 21] ]):\n",
	"	\n",
	"	assert_that(a+b+c).is_equal(expected)\n"
	]
	var fs = _parser.extract_func_signature(source_code, 0)
	
	assert_that(fs).is_equal("func test_parameterized(a: int, b :int, c :int, expected :int, parameters = [[1, 2, 3, 6],[3, 4, 5, 11],[6, 7, 8, 21] ]):")

func test_parse_func_description_paramized_test():
	var fd = _parser.parse_func_description("functest_parameterized(a:int,b:int,c:int,expected:int,parameters=[[1,2,3,6],[3,4,5,11],[6,7,8,21]]):", "class", ["path"], 22)
	
	assert_that(fd).is_equal(GdFunctionDescriptor.new("test_parameterized", 22, false, false, false, TYPE_NIL, "", [
		GdFunctionArgument.new("a", "int"),
		GdFunctionArgument.new("b", "int"),
		GdFunctionArgument.new("c", "int"),
		GdFunctionArgument.new("expected", "int"),
		GdFunctionArgument.new("parameters", "Array", "[[1,2,3,6],[3,4,5,11],[6,7,8,21]]"),
	]))

func test_parse_func_descriptor_with_fuzzers():
	var source_code := """
	func test_foo(fuzzer_a = fuzz_a(), fuzzer_b := fuzz_b(),
		fuzzer_c :Fuzzer = fuzz_c(),
		fuzzer = Fuzzers.random_rangei(-23, 22),
		fuzzer_iterations = 234,
		fuzzer_seed = 100):
	""".split("\n")
	var fs = _parser.extract_func_signature(source_code, 0)
	var fd = _parser.parse_func_description(fs, "class", ["path"], 22)
	
	assert_that(fd).is_equal(GdFunctionDescriptor.new("test_foo", 22, false, false, false, TYPE_NIL, "", [
		GdFunctionArgument.new("fuzzer_a", "Fuzzer", "fuzz_a()"),
		GdFunctionArgument.new("fuzzer_b", "Fuzzer", "fuzz_b()"),
		GdFunctionArgument.new("fuzzer_c", "Fuzzer", "fuzz_c()"),
		GdFunctionArgument.new("fuzzer", "Fuzzer", "Fuzzers.random_rangei(-23, 22)"),
		GdFunctionArgument.new("fuzzer_iterations", "int", "234"),
		GdFunctionArgument.new("fuzzer_seed", "int", "100")
	]))

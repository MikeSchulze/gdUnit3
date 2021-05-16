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

func test_parse_fuzzer_single_argument():
	assert_that(_parser.parse_fuzzer("func test_foo(fuzzer = Fuzzers.random_rangei(-23, 22))")) \
		.is_equal("fuzzer=Fuzzers.random_rangei(-23,22)")
	# test with bad formatting
	assert_that(_parser.parse_fuzzer("func test_foo(  	fuzzer  :	= Fuzzers.random_rangei(	-23,	 22))")) \
		.is_equal("fuzzer:=Fuzzers.random_rangei(-23,22)")
	assert_that(_parser.parse_fuzzer("func test_foo(fuzzer :Fuzzer = Fuzzers.random_rangei(-23, 22))")) \
		.is_equal("fuzzer:Fuzzer=Fuzzers.random_rangei(-23,22)")
	assert_that(_parser.parse_fuzzer("func test_foo(fuzzer = fuzzer())")) \
		.is_equal("fuzzer=fuzzer()")

func test_parse_fuzzer_multiple_argument():
	assert_that(_parser.parse_fuzzer("func test_foo(fuzzer = Fuzzers.random_rangei(-23, 22), arg1=42)")) \
		.is_equal("fuzzer=Fuzzers.random_rangei(-23,22)")
	assert_that(_parser.parse_fuzzer("func test_foo(fuzzer := Fuzzers.random_rangei(-23, 22), arg1=42)")) \
		.is_equal("fuzzer:=Fuzzers.random_rangei(-23,22)")
	assert_that(_parser.parse_fuzzer("func test_foo(fuzzer :Fuzzer = Fuzzers.random_rangei(-23, 22), arg1=42)")) \
		.is_equal("fuzzer:Fuzzer=Fuzzers.random_rangei(-23,22)")
	assert_that(_parser.parse_fuzzer("func test_foo(fuzzer = fuzzer(), arg1=42)")) \
		.is_equal("fuzzer=fuzzer()")

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
			GdFunctionArgument.new("arg1", "int", ""), 
			GdFunctionArgument.new("arg2", "int", "23"),
			GdFunctionArgument.new("name", "String", "\"test\"")])
	
	assert_array(_parser.parse_arguments("func foo(arg1, arg2=value(1,2,3), name:=foo()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1"), 
			GdFunctionArgument.new("arg2", "", "value(1,2,3)"),
			GdFunctionArgument.new("name", "", "foo()")])
	# enum as prefix in value name
	assert_array(_parser.parse_arguments("func get_value( type := ENUM_A) -> int:"))\
		.contains_exactly([GdFunctionArgument.new("type", "", "ENUM_A")])

func test_parse_arguments_default_build_in_type_String():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=\"default\"):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "\"default\"")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=\"default\"):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "\"default\"")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :String =\"default\"):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "String", "\"default\"")])

func test_parse_arguments_default_build_in_type_Boolean():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "false")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "false")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :bool=false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "bool", "false")])

func test_parse_arguments_default_build_in_type_Real():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=3.14):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "3.14")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=3.14):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "3.14")])
	
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
			GdFunctionArgument.new("arg2", "Array", "[1,2,3]")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=[1, 2, 3]):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "[1,2,3]")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=[]):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "[]")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :Array=[1, 2, 3], arg3 := false):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Array", "[1,2,3]"),
			GdFunctionArgument.new("arg3", "", "false")])

func test_parse_arguments_default_build_in_type_Color():
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2=Color.red):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "Color.red")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :=Color.red):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "Color.red")])
	
	assert_array(_parser.parse_arguments("func foo(arg1 :String, arg2 :Color=Color.red):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Color", "Color.red")])

func test_parse_arguments_default_build_in_type_Vector():
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 =Vector3.FORWARD):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "Vector3.FORWARD")])
	
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 :=Vector3.FORWARD):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "Vector3.FORWARD")])
	
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 :Vector3=Vector3.FORWARD):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "Vector3", "Vector3.FORWARD")])

func test_parse_arguments_default_build_in_type_AABB():
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 := AABB()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "AABB()")])
	
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 :AABB=AABB()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "AABB", "AABB()")])

func test_parse_arguments_default_build_in_types():
	assert_array(_parser.parse_arguments("func bar(arg1 :String, arg2 := Vector3.FORWARD, aabb := AABB()):")) \
		.contains_exactly([
			GdFunctionArgument.new("arg1", "String"),
			GdFunctionArgument.new("arg2", "", "Vector3.FORWARD"),
			GdFunctionArgument.new("aabb", "", "AABB()")])

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
	var fd := _parser.parse_func_description("func foo():", "clazz_name", [""])
	assert_str(fd.name()).is_equal("foo")
	assert_bool(fd.is_static()).is_false()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).is_empty()
	assert_str(fd.typeless()).is_equal("func foo():")
	
	# static function
	fd = _parser.parse_func_description("static func foo(arg1 :int, arg2:=false) -> String:", "clazz_name", [""])
	assert_str(fd.name()).is_equal("foo")
	assert_bool(fd.is_static()).is_true()
	assert_int(fd.return_type()).is_equal(TYPE_STRING)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("arg1", "int"),
		GdFunctionArgument.new("arg2", "", "false")
	])
	assert_str(fd.typeless()).is_equal("static func foo(arg1, arg2=false) -> String:")
	
	# static function without return type
	fd = _parser.parse_func_description("static func foo(arg1 :int, arg2:=false):", "clazz_name", [""])
	assert_str(fd.name()).is_equal("foo")
	assert_bool(fd.is_static()).is_true()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("arg1", "int"),
		GdFunctionArgument.new("arg2", "", "false")
	])
	assert_str(fd.typeless()).is_equal("static func foo(arg1, arg2=false):")

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
		GdFunctionDescriptor.new("foo2", false, false, false, TYPE_NIL, "", []),
		GdFunctionDescriptor.new("bar2", false, false, false, TYPE_STRING, "", [])
	])
	
	# extends from CustomResourceTestClass
	clazz_desccriptor = clazz_desccriptor.parent()
	assert_object(clazz_desccriptor).is_not_null()
	assert_str(clazz_desccriptor.name()).is_equal("CustomResourceTestClass")
	assert_bool(clazz_desccriptor.is_inner_class()).is_false()
	assert_array(clazz_desccriptor.functions()).contains_exactly([
		GdFunctionDescriptor.new("foo", false, false, false, TYPE_STRING, "", []),
		GdFunctionDescriptor.new("foo2", false, false, false, TYPE_NIL, "", []),
		GdFunctionDescriptor.new("foo_void", false, false, false, GdObjects.TYPE_VOID, "", []),
		GdFunctionDescriptor.new("bar", false, false, false, TYPE_STRING, "", [
			GdFunctionArgument.new("arg1", "int"),
			GdFunctionArgument.new("arg2", "int", "23"),
			GdFunctionArgument.new("name", "String", "\"test\""),
		]),
		GdFunctionDescriptor.new("foo5", false, false, false, TYPE_NIL, "", []),
	])
	
	# no other class extends
	clazz_desccriptor = clazz_desccriptor.parent()
	assert_object(clazz_desccriptor).is_null()

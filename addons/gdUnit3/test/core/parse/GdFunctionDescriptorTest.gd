# GdUnit generated TestSuite
class_name GdFunctionDescriptorTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/parse/GdFunctionDescriptor.gd'

# helper to get method descriptor
static func get_method_description(clazz_name :String, method_name :String) -> Dictionary:
	var method_list :Array = ClassDB.class_get_method_list(clazz_name)
	for method_descriptor in method_list:
		if method_descriptor["name"] == method_name:
			return method_descriptor
	return Dictionary()

func test_extract_from_func_without_return_type():
	var method_descriptor := get_method_description("Node", "add_child_below_node")
	var fd := GdFunctionDescriptor.extract_from(method_descriptor)
	assert_str(fd.name()).is_equal("add_child_below_node")
	assert_bool(fd.is_virtual()).is_false()
	assert_bool(fd.is_static()).is_false()
	assert_bool(fd.is_engine()).is_true()
	assert_bool(fd.is_vararg()).is_false()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("node_", "Node"),
		GdFunctionArgument.new("child_node_", "Node"),
		GdFunctionArgument.new("legible_unique_name_", "bool", "false"),
	])
	# void add_child_below_node(node: Node, child_node: Node, legible_unique_name: bool = false)
	assert_str(fd.typeless()).is_equal("func add_child_below_node(node_, child_node_, legible_unique_name_=false):")

func test_extract_from_func_with_return_type():
	var method_descriptor := get_method_description("Node", "find_node")
	var fd := GdFunctionDescriptor.extract_from(method_descriptor)
	assert_str(fd.name()).is_equal("find_node")
	assert_bool(fd.is_virtual()).is_false()
	assert_bool(fd.is_static()).is_false()
	assert_bool(fd.is_engine()).is_true()
	assert_bool(fd.is_vararg()).is_false()
	assert_int(fd.return_type()).is_equal(TYPE_OBJECT)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("mask_", "String"),
		GdFunctionArgument.new("recursive_", "bool", "true"),
		GdFunctionArgument.new("owned_", "bool", "true"),
	])
	# Node find_node(mask: String, recursive: bool = true, owned: bool = true) const
	assert_str(fd.typeless()).is_equal("func find_node(mask_, recursive_=true, owned_=true) -> Node:")

func test_extract_from_func_with_vararg():
	# void emit_signal(signal: String, ...) vararg
	var method_descriptor := get_method_description("Node", "emit_signal")
	var fd := GdFunctionDescriptor.extract_from(method_descriptor)
	assert_str(fd.name()).is_equal("emit_signal")
	assert_bool(fd.is_virtual()).is_false()
	assert_bool(fd.is_static()).is_false()
	assert_bool(fd.is_engine()).is_true()
	assert_bool(fd.is_vararg()).is_true()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).contains_exactly([GdFunctionArgument.new("signal_", "String")])
	assert_array(fd.varargs()).contains_exactly([
		GdFunctionArgument.new("vararg0_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg1_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg2_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg3_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg4_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg5_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg6_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg7_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg8_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE),
		GdFunctionArgument.new("vararg9_", "VarArg", "\"%s\"" % GdObjects.TYPE_VARARG_PLACEHOLDER_VALUE)
	])
	assert_str(fd.typeless()).is_equal("func emit_signal(signal_, vararg0_=\"__null__\", vararg1_=\"__null__\", vararg2_=\"__null__\", vararg3_=\"__null__\", vararg4_=\"__null__\", vararg5_=\"__null__\", vararg6_=\"__null__\", vararg7_=\"__null__\", vararg8_=\"__null__\", vararg9_=\"__null__\"):")

func test_extract_from_descriptor_is_virtual_func():
	var method_descriptor := get_method_description("Node", "_enter_tree")
	var fd := GdFunctionDescriptor.extract_from(method_descriptor)
	assert_str(fd.name()).is_equal("_enter_tree")
	assert_bool(fd.is_virtual()).is_true()
	assert_bool(fd.is_static()).is_false()
	assert_bool(fd.is_engine()).is_true()
	assert_bool(fd.is_vararg()).is_false()
	assert_int(fd.return_type()).is_equal(TYPE_NIL)
	assert_array(fd.args()).is_empty()
	# void _enter_tree() virtual
	assert_str(fd.typeless()).is_equal("func _enter_tree():")

func test_extract_from_descriptor_is_virtual_func_full_check():
	var methods := ClassDB.class_get_method_list("Node")
	var expected_virtual_functions := [
		# Object virtuals
		"_get",
		"_get_property_list",
		"_init",
		"_notification",
		"_set",
		"_to_string",
		# Note virtuals
		"_enter_tree",
		"_exit_tree",
		"_get_configuration_warning",
		"_input",
		"_physics_process",
		"_process",
		"_ready",
		"_unhandled_input",
		"_unhandled_key_input"
	]
	var _count := 0
	for method_descriptor in methods:
		var fd := GdFunctionDescriptor.extract_from(method_descriptor)
		
		if fd.is_virtual():
			_count += 1
			assert_array(expected_virtual_functions).contains([fd.name()])
	assert_int(_count).is_equal(expected_virtual_functions.size())

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
	assert_bool(fd.is_static()).is_false()
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
	assert_bool(fd.is_static()).is_false()
	assert_int(fd.return_type()).is_equal(TYPE_OBJECT)
	assert_array(fd.args()).contains_exactly([
		GdFunctionArgument.new("mask_", "String"),
		GdFunctionArgument.new("recursive_", "bool", "true"),
		GdFunctionArgument.new("owned_", "bool", "true"),
	])
	# Node find_node(mask: String, recursive: bool = true, owned: bool = true) const
	assert_str(fd.typeless()).is_equal("func find_node(mask_, recursive_=true, owned_=true) -> Node:")

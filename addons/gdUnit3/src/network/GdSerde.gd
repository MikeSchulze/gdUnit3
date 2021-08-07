# This class holds all necesarry stuff to serialize and deserialise GdUnit classes
# where is send over rpc 
class_name GdSerde
extends Resource

static func serialize_test_suite(test_suite:GdUnitTestSuite) -> Dictionary:
	var serialized := Dictionary()
	serialized["name"] = test_suite.get_name()
	serialized["resource_path"] = test_suite.get_script().resource_path
	var test_cases := Array()
	serialized["test_cases"] = test_cases
	for test_case in test_suite.get_children():
		test_cases.append(_TestCase.serialize(test_case))
	return serialized
	
static func deserialize_test_suite(serialized:Dictionary) -> GdUnitTestSuite:
	var resource_path :String = serialized["resource_path"]
	var test_suite := load(resource_path).new() as GdUnitTestSuite
	test_suite.set_name(serialized["name"])
	var test_cases:Array = serialized["test_cases"]
	for test_case in test_cases:
		test_suite.add_child(_TestCase.deserialize(test_case))
	return test_suite

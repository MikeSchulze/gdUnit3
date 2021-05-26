class_name GdUnitTestResourceLoader
extends Reference

static func extract_suite_name(resource_path :String) -> String:
	return resource_path.get_file().replace(".resource", "")

static func load_test_suite(resource_path :String) -> GdUnitTestSuite:
	var script := GDScript.new()
	script.source_code = GdUnitTools.resource_as_string(resource_path)
	script.resource_path = resource_path
	script.reload()
	var test_suite :GdUnitTestSuite = GdUnitTestSuite.new()
	test_suite.set_script(script)
	test_suite.set_name(extract_suite_name(resource_path))
	# complete test suite wiht parsed test cases
	var suite_parser := _TestSuiteScanner.new()
	var test_case_names := suite_parser._extract_test_case_names(test_suite)
	# add test cases to test suite and parse test case line nummber
	suite_parser._parse_and_add_test_cases(test_suite, resource_path, test_case_names)
	suite_parser.free()
	return test_suite

# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name TestSuiteScannerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/_TestSuiteScanner.gd'

func before_test():
	ProjectSettings.set_setting(GdUnitSettings.TEST_SITE_NAMING_CONVENTION, GdUnitSettings.NAMING_CONVENTIONS.AUTO_DETECT)
	GdUnitTools.clear_tmp()

func after():
	GdUnitTools.clear_tmp()

func resolve_path(source_file :String) -> String:
	return _TestSuiteScanner.resolve_test_suite_path(source_file, "_test_")

func test_resolve_test_suite_path_project() -> void:
	# if no `src` folder found use test folder as root
	assert_str(resolve_path("res://foo.gd")).is_equal("res://_test_/foo_test.gd")
	assert_str(resolve_path("res://project_name/module/foo.gd")).is_equal("res://_test_/project_name/module/foo_test.gd")
	# otherwise build relative to 'src'
	assert_str(resolve_path("res://src/foo.gd")).is_equal("res://_test_/foo_test.gd")
	assert_str(resolve_path("res://project_name/src/foo.gd")).is_equal("res://project_name/_test_/foo_test.gd")
	assert_str(resolve_path("res://project_name/src/module/foo.gd")).is_equal("res://project_name/_test_/module/foo_test.gd")
	
func test_resolve_test_suite_path_plugins() -> void:
	assert_str(resolve_path("res://addons/plugin_a/foo.gd")).is_equal("res://addons/plugin_a/_test_/foo_test.gd")
	assert_str(resolve_path("res://addons/plugin_a/src/foo.gd")).is_equal("res://addons/plugin_a/_test_/foo_test.gd")



func test_resolve_test_suite_path__no_test_root():
	# from a project path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://project/src/models/events/ModelChangedEvent.gd", ""))\
		.is_equal("res://project/src/models/events/ModelChangedEventTest.gd")
	# from a plugin path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://addons/MyPlugin/src/models/events/ModelChangedEvent.gd", ""))\
		.is_equal("res://addons/MyPlugin/src/models/events/ModelChangedEventTest.gd")
	# located in user path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("user://project/src/models/events/ModelChangedEvent.gd", ""))\
		.is_equal("user://project/src/models/events/ModelChangedEventTest.gd")

func test_resolve_test_suite_path__path_contains_src_folder():
	# from a project path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://project/src/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://project/test/models/events/ModelChangedEventTest.gd")
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://project/src/models/events/ModelChangedEvent.gd", "custom_test"))\
		.is_equal("res://project/custom_test/models/events/ModelChangedEventTest.gd")
	# from a plugin path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://addons/MyPlugin/src/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://addons/MyPlugin/test/models/events/ModelChangedEventTest.gd")
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://addons/MyPlugin/src/models/events/ModelChangedEvent.gd", "custom_test"))\
		.is_equal("res://addons/MyPlugin/custom_test/models/events/ModelChangedEventTest.gd")
	# located in user path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("user://project/src/models/events/ModelChangedEvent.gd"))\
		.is_equal("user://project/test/models/events/ModelChangedEventTest.gd")
	assert_str(_TestSuiteScanner.resolve_test_suite_path("user://project/src/models/events/ModelChangedEvent.gd", "custom_test"))\
		.is_equal("user://project/custom_test/models/events/ModelChangedEventTest.gd")
		
func test_resolve_test_suite_path__path_not_contains_src_folder():
	# from a project path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://project/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://test/project/models/events/ModelChangedEventTest.gd")
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://project/models/events/ModelChangedEvent.gd", "custom_test"))\
		.is_equal("res://custom_test/project/models/events/ModelChangedEventTest.gd")
	# from a plugin path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://addons/MyPlugin/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://addons/MyPlugin/test/models/events/ModelChangedEventTest.gd")
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://addons/MyPlugin/models/events/ModelChangedEvent.gd", "custom_test"))\
		.is_equal("res://addons/MyPlugin/custom_test/models/events/ModelChangedEventTest.gd")
	# located in user path
	assert_str(_TestSuiteScanner.resolve_test_suite_path("user://project/models/events/ModelChangedEvent.gd"))\
		.is_equal("user://test/project/models/events/ModelChangedEventTest.gd")
	assert_str(_TestSuiteScanner.resolve_test_suite_path("user://project/models/events/ModelChangedEvent.gd", "custom_test"))\
		.is_equal("user://custom_test/project/models/events/ModelChangedEventTest.gd")

func test_test_suite_exists():
	var path_exists := "res://addons/gdUnit3/test/resources/core/GeneratedPersonTest.gd"
	var path_not_exists := "res://addons/gdUnit3/test/resources/core/FamilyTest.gd"
	assert_that(_TestSuiteScanner.test_suite_exists(path_exists)).is_true()
	assert_that(_TestSuiteScanner.test_suite_exists(path_not_exists)).is_false()

func test_test_case_exists():
	var test_suite_path := "res://addons/gdUnit3/test/resources/core/GeneratedPersonTest.gd"
	assert_that(_TestSuiteScanner.test_case_exists(test_suite_path, "name")).is_true()
	assert_that(_TestSuiteScanner.test_case_exists(test_suite_path, "last_name")).is_false()

func test_create_test_suite_pascal_case_path():
	var temp_dir := GdUnitTools.create_temp_dir("TestSuiteScannerTest")
	# on source with class_name is set
	var source_path := "res://addons/gdUnit3/test/core/resources/naming_conventions/PascalCaseWithClassName.gd"
	var suite_path := temp_dir + "/test/MyClassTest1.gd"
	var result := _TestSuiteScanner.create_test_suite(suite_path, source_path)
	assert_that(result.is_success()).is_true()
	assert_str(result.value()).is_equal(suite_path)
	assert_file(result.value()).exists()\
		.is_file()\
		.is_script()\
		.contains_exactly([
			"# GdUnit generated TestSuite",
			"#warning-ignore-all:unused_argument",
			"#warning-ignore-all:return_value_discarded",
			"class_name PascalCaseWithClassNameTest",
			"extends GdUnitTestSuite",
			"",
			"# TestSuite generated from",
			"const __source = '%s'" % source_path,
			""])
	# on source with class_name is NOT set
	source_path = "res://addons/gdUnit3/test/core/resources/naming_conventions/PascalCaseWithoutClassName.gd"
	suite_path = temp_dir + "/test/MyClassTest2.gd"
	result = _TestSuiteScanner.create_test_suite(suite_path, source_path)
	assert_that(result.is_success()).is_true()
	assert_str(result.value()).is_equal(suite_path)
	assert_file(result.value()).exists()\
		.is_file()\
		.is_script()\
		.contains_exactly([
			"# GdUnit generated TestSuite",
			"#warning-ignore-all:unused_argument",
			"#warning-ignore-all:return_value_discarded",
			"class_name PascalCaseWithoutClassNameTest",
			"extends GdUnitTestSuite",
			"",
			"# TestSuite generated from",
			"const __source = '%s'" % source_path,
			""])

func test_create_test_suite_snake_case_path():
	var temp_dir := GdUnitTools.create_temp_dir("TestSuiteScannerTest")
	# on source with class_name is set
	var source_path :="res://addons/gdUnit3/test/core/resources/naming_conventions/snake_case_with_class_name.gd"
	var suite_path := temp_dir + "/test/my_class_test1.gd"
	var result := _TestSuiteScanner.create_test_suite(suite_path, source_path)
	assert_that(result.is_success()).is_true()
	assert_str(result.value()).is_equal(suite_path)
	assert_file(result.value()).exists()\
		.is_file()\
		.is_script()\
		.contains_exactly([
			"# GdUnit generated TestSuite",
			"#warning-ignore-all:unused_argument",
			"#warning-ignore-all:return_value_discarded",
			"class_name SnakeCaseWithClassNameTest",
			"extends GdUnitTestSuite",
			"",
			"# TestSuite generated from",
			"const __source = '%s'" % source_path,
			""])
	# on source with class_name is NOT set
	source_path ="res://addons/gdUnit3/test/core/resources/naming_conventions/snake_case_without_class_name.gd"
	suite_path = temp_dir + "/test/my_class_test2.gd"
	result = _TestSuiteScanner.create_test_suite(suite_path, source_path)
	assert_that(result.is_success()).is_true()
	assert_str(result.value()).is_equal(suite_path)
	assert_file(result.value()).exists()\
		.is_file()\
		.is_script()\
		.contains_exactly([
			"# GdUnit generated TestSuite",
			"#warning-ignore-all:unused_argument",
			"#warning-ignore-all:return_value_discarded",
			"class_name SnakeCaseWithoutClassNameTest",
			"extends GdUnitTestSuite",
			"",
			"# TestSuite generated from",
			"const __source = '%s'" % source_path,
			""])

func test_create_test_case():
	# store test class on temp dir
	var tmp_path := GdUnitTools.create_temp_dir("TestSuiteScannerTest")
	var source_path := "res://addons/gdUnit3/test/resources/core/Person.gd"
	# generate new test suite with test 'test_last_name()'
	var test_suite_path = tmp_path + "/test/PersonTest.gd"
	var result := _TestSuiteScanner.create_test_case(test_suite_path, "last_name", source_path)
	assert_that(result.is_success()).is_true()
	var info :Dictionary = result.value()
	assert_int(info.get("line")).is_equal(10)
	assert_file(info.get("path")).exists()\
		.is_file()\
		.is_script()\
		.contains_exactly([
			"# GdUnit generated TestSuite",
			"#warning-ignore-all:unused_argument",
			"#warning-ignore-all:return_value_discarded",
			"class_name PersonTest",
			"extends GdUnitTestSuite",
			"",
			"# TestSuite generated from",
			"const __source = '%s'" % source_path,
			"",
			"func test_last_name() -> void:",
			"	# remove this line and complete your test",
			"	assert_not_yet_implemented()",
			""])
	# try to add again
	result = _TestSuiteScanner.create_test_case(test_suite_path, "last_name", source_path)
	assert_that(result.is_success()).is_true()
	assert_that(result.value()).is_equal({"line" : 10, "path": test_suite_path})

# https://github.com/MikeSchulze/gdUnit3/issues/25
func test_build_test_suite_path() -> void:
	# on project root
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://new_script.gd")).is_equal("res://test/new_script_test.gd")
	
	# on project without src folder
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://foo/bar/new_script.gd")).is_equal("res://test/foo/bar/new_script_test.gd")
	
	# project code structured by 'src'
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://src/new_script.gd")).is_equal("res://test/new_script_test.gd")
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://src/foo/bar/new_script.gd")).is_equal("res://test/foo/bar/new_script_test.gd")
	# folder name contains 'src' in name
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://foo/srcare/new_script.gd")).is_equal("res://test/foo/srcare/new_script_test.gd")
	
	# on plugins without src folder
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://addons/plugin/foo/bar/new_script.gd")).is_equal("res://addons/plugin/test/foo/bar/new_script_test.gd")
	# plugin code structured by 'src'
	assert_str(_TestSuiteScanner.resolve_test_suite_path("res://addons/plugin/src/foo/bar/new_script.gd")).is_equal("res://addons/plugin/test/foo/bar/new_script_test.gd")
	
	# on user temp folder
	var tmp_path := GdUnitTools.create_temp_dir("projectX/entity")
	var source_path := tmp_path + "/Person.gd"
	assert_str(_TestSuiteScanner.resolve_test_suite_path(source_path)).is_equal("user://tmp/test/projectX/entity/PersonTest.gd")

func test_parse_and_add_test_cases() -> void:
	var default_time := GdUnitSettings.test_timeout()
	var scanner :_TestSuiteScanner = auto_free(_TestSuiteScanner.new())
	# fake a test suite
	var test_suite :GdUnitTestSuite = auto_free(GdUnitTestSuite.new())
	var script := GDScript.new()
	script.resource_path = "res://addons/gdUnit3/test/core/resources/test_script_with_arguments.gd"
	var file := File.new()
	file.open(script.resource_path, File.READ)
	var line_number:int = 0
	file.seek(0)
	script.source_code = file.get_as_text()
	file.close()
	
	test_suite.set_script(script)
	var test_case_names := PoolStringArray([
		"test_no_args",
		"test_with_timeout",
		"test_with_fuzzer",
		"test_with_fuzzer_iterations",
		"test_with_multible_fuzzers",
		"test_multiline_arguments_a",
		"test_multiline_arguments_b",
		"test_multiline_arguments_c"])
	scanner._parse_and_add_test_cases(test_suite, test_suite.get_script(), test_case_names)
	assert_array(test_suite.get_children())\
		.extractv(extr("get_name"), extr("timeout"), extr("fuzzers"), extr("iterations"))\
		.contains_exactly([
			tuple("test_no_args", default_time, PoolStringArray(), 1),
			tuple("test_with_timeout", 2000, PoolStringArray(), 1),
			tuple("test_with_fuzzer", default_time, PoolStringArray(["fuzzer:=Fuzzers.rangei(-10,22)"]), Fuzzer.ITERATION_DEFAULT_COUNT),
			tuple("test_with_fuzzer_iterations", default_time, PoolStringArray(["fuzzer:=Fuzzers.rangei(-10,22)"]), 10),
			tuple("test_with_multible_fuzzers", default_time, PoolStringArray(["fuzzer_a:=Fuzzers.rangei(-10,22)", "fuzzer_b:=Fuzzers.rangei(23,42)"]), 10),
			tuple("test_multiline_arguments_a", default_time, PoolStringArray(["fuzzer_a:=Fuzzers.rangei(-10,22)", "fuzzer_b:=Fuzzers.rangei(23,42)"]), 42),
			tuple("test_multiline_arguments_b", default_time, PoolStringArray(["fuzzer_a:=Fuzzers.rangei(-10,22)", "fuzzer_b:=Fuzzers.rangei(23,42)"]), 23),
			tuple("test_multiline_arguments_c", 2000, PoolStringArray(["fuzzer_a:=Fuzzers.rangei(-10,22)", "fuzzer_b:=Fuzzers.rangei(23,42)"]), 33),
		])

func test_scan_by_inheritance_class_name() -> void:
	var scanner :_TestSuiteScanner = auto_free(_TestSuiteScanner.new())
	var test_suites := scanner.scan("res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_name/")
	
	assert_array(test_suites).extractv(extr("get_name"), extr("get_script.get_path"), extr("get_children.get_name"))\
		.contains_exactly_in_any_order([
			tuple("BaseTest", "res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_name/BaseTest.gd", ["test_foo1"]),
			tuple("ExtendedTest","res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_name/ExtendedTest.gd", ["test_foo2", "test_foo1"]), 
			tuple("ExtendsExtendedTest", "res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_name/ExtendsExtendedTest.gd", ["test_foo3", "test_foo2", "test_foo1"])
		])
	# finally free all scaned test suites
	for ts in test_suites:
		ts.free()

func test_scan_by_inheritance_class_path() -> void:
	var scanner :_TestSuiteScanner = auto_free(_TestSuiteScanner.new())
	var test_suites := scanner.scan("res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_path/")
	
	assert_array(test_suites).extractv(extr("get_name"), extr("get_script.get_path"), extr("get_children.get_name"))\
		.contains_exactly_in_any_order([
			tuple("BaseTest", "res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_path/BaseTest.gd", ["test_foo1"]),
			tuple("ExtendedTest","res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_path/ExtendedTest.gd", ["test_foo2", "test_foo1"]), 
			tuple("ExtendsExtendedTest", "res://addons/gdUnit3/test/core/resources/scan_testsuite_inheritance/by_class_path/ExtendsExtendedTest.gd", ["test_foo3", "test_foo2", "test_foo1"])
		])
	# finally free all scaned test suites
	for ts in test_suites:
		ts.free()

func test_get_test_case_line_number() -> void:
	assert_int(_TestSuiteScanner.get_test_case_line_number("res://addons/gdUnit3/test/core/TestSuiteScannerTest.gd", "get_test_case_line_number")).is_equal(295)
	assert_int(_TestSuiteScanner.get_test_case_line_number("res://addons/gdUnit3/test/core/TestSuiteScannerTest.gd", "unknown")).is_equal(-1)

func test__to_naming_convention() -> void:
	ProjectSettings.set_setting(GdUnitSettings.TEST_SITE_NAMING_CONVENTION, GdUnitSettings.NAMING_CONVENTIONS.AUTO_DETECT)
	assert_str(_TestSuiteScanner._to_naming_convention("MyClass")).is_equal("MyClassTest")
	assert_str(_TestSuiteScanner._to_naming_convention("my_class")).is_equal("my_class_test")
	assert_str(_TestSuiteScanner._to_naming_convention("myclass")).is_equal("myclass_test")
	
	ProjectSettings.set_setting(GdUnitSettings.TEST_SITE_NAMING_CONVENTION, GdUnitSettings.NAMING_CONVENTIONS.SNAKE_CASE)
	assert_str(_TestSuiteScanner._to_naming_convention("MyClass")).is_equal("my_class_test")
	assert_str(_TestSuiteScanner._to_naming_convention("my_class")).is_equal("my_class_test")
	assert_str(_TestSuiteScanner._to_naming_convention("myclass")).is_equal("myclass_test")
	
	ProjectSettings.set_setting(GdUnitSettings.TEST_SITE_NAMING_CONVENTION, GdUnitSettings.NAMING_CONVENTIONS.PASCAL_CASE)
	assert_str(_TestSuiteScanner._to_naming_convention("MyClass")).is_equal("MyClassTest")
	assert_str(_TestSuiteScanner._to_naming_convention("my_class")).is_equal("MyClassTest")
	assert_str(_TestSuiteScanner._to_naming_convention("myclass")).is_equal("MyclassTest")

func test_is_script_format_supported() -> void:
	assert_bool(_TestSuiteScanner._is_script_format_supported("res://exampe.gd")).is_true()
	if GdUnitTools.is_mono_supported():
		assert_bool(_TestSuiteScanner._is_script_format_supported("res://exampe.cs")).is_true()
	else:
		assert_bool(_TestSuiteScanner._is_script_format_supported("res://exampe.cs")).is_false()
	assert_bool(_TestSuiteScanner._is_script_format_supported("res://exampe.gdns")).is_false()
	assert_bool(_TestSuiteScanner._is_script_format_supported("res://exampe.vs")).is_false()
	assert_bool(_TestSuiteScanner._is_script_format_supported("res://exampe.tres")).is_false()

func test_load_parameterized_test_suite():
	var scanner :_TestSuiteScanner = auto_free(_TestSuiteScanner.new())
	var test_suites := scanner.scan("res://addons/gdUnit3/test/core/resources/testsuites/ParameterizedTestSuite.gd")
	
	assert_array(test_suites).extractv(extr("get_name"), extr("get_script.get_path"), extr("get_children.get_name"))\
		.contains_exactly_in_any_order([
			tuple("ParameterizedTestSuite", "res://addons/gdUnit3/test/core/resources/testsuites/ParameterizedTestSuite.gd",
				["test_no_parameters",
				"test_parameterized",
				"test_parameterized_to_less_args",
				"test_parameterized_to_many_args",
				"test_parameterized_to_less_args_at_index_1",
				"test_parameterized_invalid_struct",
				"test_parameterized_invalid_args"])
		])
	# finally free all scaned test suites
	for ts in test_suites:
		ts.free()

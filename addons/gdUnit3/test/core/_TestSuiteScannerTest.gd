# GdUnit generated TestSuite
class_name _TestSuiteScannerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/_TestSuiteScanner.gd'

func before_test():
	GdUnitTools.clear_tmp()
	

func after():
	GdUnitTools.clear_tmp()

func test_build_test_suite_path__path_contains_src_folder():
	# from a project path
	assert_str(_TestSuiteScanner.build_test_suite_path("res://project/src/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://project/test/models/events/ModelChangedEventTest.gd")
	# from a plugin path
	assert_str(_TestSuiteScanner.build_test_suite_path("res://addons/MyPlugin/src/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://addons/MyPlugin/test/models/events/ModelChangedEventTest.gd")
	# located in user path
	assert_str(_TestSuiteScanner.build_test_suite_path("user://project/src/models/events/ModelChangedEvent.gd"))\
		.is_equal("user://project/test/models/events/ModelChangedEventTest.gd")
		
func test_build_test_suite_path__path_not_contains_src_folder():
	# from a project path
	assert_str(_TestSuiteScanner.build_test_suite_path("res://project/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://test/project/models/events/ModelChangedEventTest.gd")
	# from a plugin path
	assert_str(_TestSuiteScanner.build_test_suite_path("res://addons/MyPlugin/models/events/ModelChangedEvent.gd"))\
		.is_equal("res://addons/MyPlugin/test/models/events/ModelChangedEventTest.gd")
	# located in user path
	assert_str(_TestSuiteScanner.build_test_suite_path("user://project/models/events/ModelChangedEvent.gd"))\
		.is_equal("user://test/project/models/events/ModelChangedEventTest.gd")

func test_test_suite_exists():
	var path_exists := "res://addons/gdUnit3/test/resources/core/GeneratedPersonTest.gd"
	var path_not_exists := "res://addons/gdUnit3/test/resources/core/FamilyTest.gd"
	assert_that(_TestSuiteScanner.test_suite_exists(path_exists)).is_true()
	assert_that(_TestSuiteScanner.test_suite_exists(path_not_exists)).is_false()

func test_test_case_exists():
	var test_suite_path := "res://addons/gdUnit3/test/resources/core/GeneratedPersonTest.gd"
	assert_that(_TestSuiteScanner.test_case_exists(test_suite_path, "name")).is_true()
	assert_that(_TestSuiteScanner.test_case_exists(test_suite_path, "last_name")).is_false()

func test_save_test_suite():
	var temp_dir := GdUnitTools.create_temp_dir("TestSuiteScannerTest")
	var source_path := temp_dir + "/src/MyClass.gd"
	var suite_path := temp_dir + "/test/MyClassTest.gd"
	var result := _TestSuiteScanner.save_test_suite(suite_path, source_path)
	assert_that(result.is_success()).is_true()
	assert_file(result.value()).exists()\
		.is_file()\
		.is_script()\
		.contains_exactly([
			"# GdUnit generated TestSuite",
			"class_name MyClassTest",
			"extends GdUnitTestSuite",
			"",
			"# TestSuite generated from",
			"const __source = '%s'" % source_path,
			""])

func test_create_test_case():
	# store test class on temp dir
	var tmp_path := GdUnitTools.create_temp_dir("project/entity")
	var source_path := tmp_path + "/Person.gd"
	# copy test class from resources to temp
	if Directory.new().copy("res://addons/gdUnit3/test/resources/core/Person.gd", source_path) != OK:
		push_error("can't copy resouces")
	# generate new test suite with test 'test_last_name()'
	var result := _TestSuiteScanner.create_test_case(source_path, "last_name")
	assert_that(result.is_success()).is_true()
	var info :Dictionary = result.value()
	assert_int(info.get("line")).is_equal(8)
	assert_file(info.get("path")).exists()\
		.is_file()\
		.is_script()\
		.contains_exactly([
			"# GdUnit generated TestSuite",
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
	result = _TestSuiteScanner.create_test_case(source_path, "last_name")
	assert_that(result.is_warn()).is_true()
	assert_that(result.warn_message()).is_equal("Test Case 'test_last_name' already exists in 'user://tmp/test/project/entity/PersonTest.gd'")

# https://github.com/MikeSchulze/gdUnit3/issues/25
func test_build_test_suite_path() -> void:
	# on project root
	assert_str(_TestSuiteScanner.build_test_suite_path("res://new_script.gd")).is_equal("res://test/new_scriptTest.gd")
	
	# on project without src folder
	assert_str(_TestSuiteScanner.build_test_suite_path("res://foo/bar/new_script.gd")).is_equal("res://test/foo/bar/new_scriptTest.gd")
	
	# project code structured by 'src'
	assert_str(_TestSuiteScanner.build_test_suite_path("res://src/new_script.gd")).is_equal("res://test/new_scriptTest.gd")
	assert_str(_TestSuiteScanner.build_test_suite_path("res://src/foo/bar/new_script.gd")).is_equal("res://test/foo/bar/new_scriptTest.gd")
	# folder name contains 'src' in name
	assert_str(_TestSuiteScanner.build_test_suite_path("res://foo/srcare/new_script.gd")).is_equal("res://test/foo/srcare/new_scriptTest.gd")
	
	# on plugins without src folder
	assert_str(_TestSuiteScanner.build_test_suite_path("res://addons/plugin/foo/bar/new_script.gd")).is_equal("res://addons/plugin/test/foo/bar/new_scriptTest.gd")
	# plugin code structured by 'src'
	assert_str(_TestSuiteScanner.build_test_suite_path("res://addons/plugin/src/foo/bar/new_script.gd")).is_equal("res://addons/plugin/test/foo/bar/new_scriptTest.gd")
	
	# on user temp folder
	var tmp_path := GdUnitTools.create_temp_dir("projectX/entity")
	var source_path := tmp_path + "/Person.gd"
	assert_str(_TestSuiteScanner.build_test_suite_path(source_path)).is_equal("user://tmp/test/projectX/entity/PersonTest.gd")

func test_parse_and_add_test_cases() -> void:
	var default_time := GdUnitSettings.test_timeout()
	var scanner = auto_free(_TestSuiteScanner.new())
	var test_suite :GdUnitTestSuite = auto_free(GdUnitTestSuite.new())
	var script_path := "res://addons/gdUnit3/test/core/resources/test_script_with_arguments.gd"
	var test_case_names := PoolStringArray(["test_no_args", "test_with_timeout", "test_whith_fuzzer", "test_whith_fuzzer_iterations"])
	scanner._parse_and_add_test_cases(test_suite, script_path, test_case_names)
	assert_array(test_suite.get_children())\
		.extractv(extr("get_name"), extr("timeout"), extr("fuzzer_func"), extr("iterations"))\
		.contains_exactly([
			tuple("test_no_args", default_time, "", 1),
			tuple("test_with_timeout", 2000, "", 1),
			tuple("test_whith_fuzzer", default_time, "fuzzer:=Fuzzers.rangei(-10,22)", Fuzzer.ITERATION_DEFAULT_COUNT),
			tuple("test_whith_fuzzer_iterations", default_time, "fuzzer:=Fuzzers.rangei(-10,22)", 10)])

# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name TestSuiteScannerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/_TestSuiteScanner.gd'


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

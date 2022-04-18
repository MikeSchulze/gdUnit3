# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdUnitTestSuiteTemplateTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/templates/test_suite/GdUnitTestSuiteTemplate.gd'

const CUSTOM_TEMPLATE = \
"""# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name ${suite_class_name}
extends GdUnitTestSuite

func before() -> void:
	var ${source_var}_1 := ${source_class}.new()
	var ${source_var}_2 = load("${source_resource_path}")
"""

func after() -> void:
	GdUnitTestSuiteTemplate.reset_to_default(TEMPLATE_ID_GD)

func test_default_template() -> void:
	assert_str(GdUnitTestSuiteTemplate.default_template()).is_equal(GdUnitTestSuiteDefaultTemplate.DEFAULT_TEMP_TS_GD)

func test_build_template_default() -> void:
	var template := GdUnitTestSuiteTemplate.build_template("res://addons/gdUnit3/test/core/resources/script_with_class_name.gd")
	var expected := \
"""# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name ScriptWithClassNameTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/test/core/resources/script_with_class_name.gd'
"""
	assert_str(template).is_equal(expected)

# on source with class_name definition
func test_build_template_custom1() -> void:
	GdUnitTestSuiteTemplate.save_template(CUSTOM_TEMPLATE)
	var template := GdUnitTestSuiteTemplate.build_template("res://addons/gdUnit3/test/core/resources/script_with_class_name.gd")
	var expected := \
"""# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name ScriptWithClassNameTest
extends GdUnitTestSuite

func before() -> void:
	var script_with_class_name_1 := ScriptWithClassName.new()
	var script_with_class_name_2 = load("res://addons/gdUnit3/test/core/resources/script_with_class_name.gd")
"""
	assert_str(template).is_equal(expected)

# on source without class_name definition
func test_build_template_custom2() -> void:
	GdUnitTestSuiteTemplate.save_template(CUSTOM_TEMPLATE)
	var template := GdUnitTestSuiteTemplate.build_template("res://addons/gdUnit3/test/core/resources/script_without_class_name.gd")
	var expected := \
"""# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name ScriptWithoutClassNameTest
extends GdUnitTestSuite

func before() -> void:
	var script_without_class_name_1 := ScriptWithoutClassName.new()
	var script_without_class_name_2 = load("res://addons/gdUnit3/test/core/resources/script_without_class_name.gd")
"""
	assert_str(template).is_equal(expected)


# on source with class_name definition pascal_case
func test_build_template_custom3() -> void:
	GdUnitTestSuiteTemplate.save_template(CUSTOM_TEMPLATE)
	var template := GdUnitTestSuiteTemplate.build_template("res://addons/gdUnit3/test/core/resources/naming_conventions/PascalCaseWithClassName.gd")
	var expected := \
"""# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name PascalCaseWithClassNameTest
extends GdUnitTestSuite

func before() -> void:
	var pascal_case_with_class_name_1 := PascalCaseWithClassName.new()
	var pascal_case_with_class_name_2 = load("res://addons/gdUnit3/test/core/resources/naming_conventions/PascalCaseWithClassName.gd")
"""
	assert_str(template).is_equal(expected)

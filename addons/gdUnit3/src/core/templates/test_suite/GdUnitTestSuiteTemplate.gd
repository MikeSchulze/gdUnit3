class_name GdUnitTestSuiteTemplate
extends Reference

const DEFAULT_TEMP_TS_GD = GdUnitTestSuiteDefaultTemplate.DEFAULT_TEMP_TS_GD
const SUPPORTED_TAGS = """
Tags are replaced when the test-suite is created.

# The class name of the test-suite, formed from the source script.
${suite_class_name}
# is used to build the test suite class name
	class_name ${suite_class_name}
	extends GdUnitTestSuite


# The class name in pascal case, formed from the source script.
${source_class}
	# can be used to create the class e.g. for source 'MyClass'
	var my_test_class := ${source_class}.new()
	# will be result in
	var my_test_class := MyClass.new()

# The class as variable name in snake case, formed from the source script.
${source_var}
	# Can be used to build the variable name e.g. for source 'MyClass'
	var ${source_var} := ${source_class}.new()
	# will be result in
	var my_class := MyClass.new()

# The full resource path from which the file was created.
${source_resource_path}
	# Can be used to load the script in your test
	var my_script := load(${source_resource_path})
	# will be result in
	var my_script := load("res://folder/my_class.gd")
"""

const TAG_TEST_SUITE_CLASS = "${suite_class_name}"
const TAG_SOURCE_CLASS_NAME = "${source_class}"
const TAG_SOURCE_CLASS_VARNAME = "${source_var}"
const TAG_SOURCE_RESOURCE_PATH = "${source_resource_path}"

static func build_template(source_path: String) -> String:
	var clazz_name :String = GdObjects.to_pascal_case(GdObjects.extract_class_name(source_path).value())
	return GdUnitSettings.get_setting(GdUnitSettings.TEMPLATE_TS_GD, DEFAULT_TEMP_TS_GD)\
		.replace(TAG_TEST_SUITE_CLASS, clazz_name+"Test")\
		.replace(TAG_SOURCE_RESOURCE_PATH, source_path)\
		.replace(TAG_SOURCE_CLASS_NAME, clazz_name)\
		.replace(TAG_SOURCE_CLASS_VARNAME, GdObjects.to_snake_case(clazz_name))

static func default_template() -> String:
	return GdUnitTestSuiteDefaultTemplate.DEFAULT_TEMP_TS_GD

static func load_template() -> String:
	return GdUnitSettings.get_setting(GdUnitSettings.TEMPLATE_TS_GD, DEFAULT_TEMP_TS_GD)

static func save_template(template :String) -> void:
	GdUnitSettings.save_property(GdUnitSettings.TEMPLATE_TS_GD, template)

static func reset_to_default() -> void:
	GdUnitSettings.save_property(GdUnitSettings.TEMPLATE_TS_GD, DEFAULT_TEMP_TS_GD)

# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name TestSuiteTemplateTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/ui/templates/TestSuiteTemplate.gd'

func test_show() -> void:
	var template = spy("res://addons/gdUnit3/src/ui/templates/TestSuiteTemplate.tscn")
	scene_runner(template)
	
	verify(template).setup_editor_colors()
	verify(template).setup_supported_types()
	verify(template).load_template()
	verify(template).setup_tags_help()

# GdUnit generated TestSuite
class_name GdUnitRunnerConfigTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitRunnerConfig.gd'

func test_load_old_format():
	assert_result(GdUnitRunnerConfig.new().load("res://addons/gdUnit3/test/core/resources/GdUnitRunner_old_format.cfg"))\
		.is_error()\
		.contains_message("The runner configuration 'res://addons/gdUnit3/test/core/resources/GdUnitRunner_old_format.cfg' is invalid! The format is changed please delete it manually and start a new test run.")

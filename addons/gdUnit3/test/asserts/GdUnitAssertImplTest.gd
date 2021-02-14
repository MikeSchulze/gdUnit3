# GdUnit generated TestSuite
class_name GdUnitAssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitAssertImpl.gd'

func test_get_line_number():
	# test to return the current line number for an failure
	assert_int(GdUnitAssertImpl._get_line_number()).is_equal(10)

func test_get_line_number_yielded():
	# test to return the current line number after using yield
	yield(get_tree().create_timer(0.100), "timeout")
	assert_int(GdUnitAssertImpl._get_line_number()).is_equal(15)

func test_get_line_number_multiline():
	# test to return the current line number for an failure
	# https://github.com/godotengine/godot/issues/43326
	assert_int(GdUnitAssertImpl\
		._get_line_number()).is_equal(20)

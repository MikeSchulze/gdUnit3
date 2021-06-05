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

func test_is_null():
	assert_that(null).is_null()
	# should fail because the current is not null
	assert_that(Color.red, GdUnitAssert.EXPECT_FAIL) \
		.is_null()\
		.starts_with_failure_message("Expecting: 'Null' but was '1,0,0,1'")

func test_is_not_null():
	assert_that(Color.red).is_not_null()
	# should fail because the current is null
	assert_that(null, GdUnitAssert.EXPECT_FAIL) \
		.is_not_null()\
		.has_failure_message("Expecting: not to be 'Null'")

func test_is_equal():
	assert_that(Color.red).is_equal(Color.red)
	assert_that(Plane.PLANE_XY).is_equal(Plane.PLANE_XY)
	assert_that(Color.red, GdUnitAssert.EXPECT_FAIL) \
		.is_equal(Color.green) \
		.has_failure_message("Expecting:\n '0,1,0,1'\n but was\n '1,0,0,1'")

func test_is_not_equal():
	assert_that(Color.red).is_not_equal(Color.green)
	assert_that(Plane.PLANE_XY).is_not_equal(Plane.PLANE_XZ)
	assert_that(Color.red, GdUnitAssert.EXPECT_FAIL) \
		.is_not_equal(Color.red) \
		.has_failure_message("Expecting:\n '1,0,0,1'\n not equal to\n '1,0,0,1'")

func test_override_failure_message() -> void:
	assert_that(Color.red, GdUnitAssert.EXPECT_FAIL)\
		.override_failure_message("Custom failure message")\
		.is_null()\
		.has_failure_message("Custom failure message")

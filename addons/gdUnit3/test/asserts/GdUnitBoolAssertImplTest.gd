# GdUnit generated TestSuite
class_name GdUnitBoolAssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitBoolAssertImpl.gd'

func test_is_true():
	assert_bool(true).is_true()
	assert_bool(false, GdUnitAssert.EXPECT_FAIL).is_true() \
		.has_error_message("Expecting: 'True' but is 'False'")

func test_isFalse():
	assert_bool(false).is_false()
	assert_bool(true, GdUnitAssert.EXPECT_FAIL).is_false() \
		.has_error_message("Expecting: 'False' but is 'True'")

func test_is_equal():
	assert_bool(true).is_equal(true)
	assert_bool(false).is_equal(false)
	assert_bool(true, GdUnitAssert.EXPECT_FAIL) \
		.is_equal(false) \
		.has_error_message("Expecting:\n 'False'\n but was\n 'True'")

func test_is_not_equal():
	assert_bool(true).is_not_equal(false)
	assert_bool(false).is_not_equal(true)
	assert_bool(true, GdUnitAssert.EXPECT_FAIL) \
		.is_not_equal(true) \
		.has_error_message("Expecting:\n 'True'\n not equal to\n 'True'")

func test_fluent():
	assert_bool(true).is_true().is_equal(true).is_not_equal(false)

func test_must_fail_has_invlalid_type():
	assert_bool(1, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitBoolAssert inital error, unexpected type <int>")
	assert_bool(3.13, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitBoolAssert inital error, unexpected type <float>")
	assert_bool("foo", GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitBoolAssert inital error, unexpected type <String>")
	assert_bool(Resource.new(), GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitBoolAssert inital error, unexpected type <Object>")
	assert_bool(null, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitBoolAssert inital error, unexpected type <null>")

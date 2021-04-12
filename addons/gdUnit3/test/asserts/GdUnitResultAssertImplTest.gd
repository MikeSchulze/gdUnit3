# GdUnit generated TestSuite
class_name GdUnitResultAssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitResultAssertImpl.gd'

func test_is_null():
	assert_result(null).is_null()
	
	assert_result(Result.success(""), GdUnitAssert.EXPECT_FAIL) \
		.is_null() \
		.has_error_message("Expecting: 'Null' but was <Reference>")

func test_is_not_null():
	assert_result(Result.success("")).is_not_null()
	
	assert_result(null, GdUnitAssert.EXPECT_FAIL) \
		.is_not_null() \
		.has_error_message("Expecting: not to be 'Null'")

func test_is_empty():
	assert_result(Result.empty()).is_empty()
	
	assert_result(Result.warn("a warning"), GdUnitAssert.EXPECT_FAIL) \
		.is_empty() \
		.has_error_message("Expecting the result must be a EMPTY but was WARNING:\n 'a warning'")
	
	assert_result(Result.error("a error"), GdUnitAssert.EXPECT_FAIL) \
		.is_empty() \
		.has_error_message("Expecting the result must be a EMPTY but was ERROR:\n 'a error'")

func test_is_success():
	assert_result(Result.success("")).is_success()
	
	assert_result(Result.warn("a warning"), GdUnitAssert.EXPECT_FAIL) \
		.is_success() \
		.has_error_message("Expecting the result must be a SUCCESS but was WARNING:\n 'a warning'")
	
	assert_result(Result.error("a error"), GdUnitAssert.EXPECT_FAIL) \
		.is_success() \
		.has_error_message("Expecting the result must be a SUCCESS but was ERROR:\n 'a error'")

func test_is_warning():
	assert_result(Result.warn("a warning")).is_warning()
	
	assert_result(Result.success("value"), GdUnitAssert.EXPECT_FAIL) \
		.is_warning() \
		.has_error_message("Expecting the result must be a WARNING but was SUCCESS.")
	
	assert_result(Result.error("a error"), GdUnitAssert.EXPECT_FAIL) \
		.is_warning() \
		.has_error_message("Expecting the result must be a WARNING but was ERROR:\n 'a error'")

func test_is_error():
	assert_result(Result.error("a error")).is_error()
	
	assert_result(Result.success(""), GdUnitAssert.EXPECT_FAIL) \
		.is_error() \
		.has_error_message("Expecting the result must be a ERROR but was SUCCESS.")
	
	assert_result(Result.warn("a warning"), GdUnitAssert.EXPECT_FAIL) \
		.is_error() \
		.has_error_message("Expecting the result must be a ERROR but was WARNING:\n 'a warning'")

func test_contains_message():
	assert_result(Result.error("a error")).contains_message("a error")
	assert_result(Result.warn("a warning")).contains_message("a warning")
	
	assert_result(Result.success(""), GdUnitAssert.EXPECT_FAIL) \
		.contains_message("Error 500") \
		.has_error_message("Expecting:\n 'Error 500'\n but the Result is a success.")
	assert_result(Result.warn("Warning xyz!"), GdUnitAssert.EXPECT_FAIL) \
		.contains_message("Warning aaa!") \
		.has_error_message("Expecting:\n 'Warning aaa!'\n but was\n 'Warning xyz!'.")
	assert_result(Result.error("Error 410"), GdUnitAssert.EXPECT_FAIL) \
		.contains_message("Error 500") \
		.has_error_message("Expecting:\n 'Error 500'\n but was\n 'Error 410'.")

func test_is_value():
	assert_result(Result.success("")).is_value("")
	var result_value = auto_free(Node.new())
	assert_result(Result.success(result_value)).is_value(result_value)
	
	assert_result(Result.success(""), GdUnitAssert.EXPECT_FAIL) \
		.is_value("abc") \
		.has_error_message("Expecting to contain same value:\n 'abc'\n but was\n ''.")
	assert_result(Result.success("abc"), GdUnitAssert.EXPECT_FAIL) \
		.is_value("") \
		.has_error_message("Expecting to contain same value:\n ''\n but was\n 'abc'.")
	assert_result(Result.success(result_value), GdUnitAssert.EXPECT_FAIL) \
		.is_value("") \
		.has_error_message("Expecting to contain same value:\n ''\n but was\n <Node>.")

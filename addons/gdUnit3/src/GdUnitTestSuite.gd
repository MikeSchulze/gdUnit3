################################################################################
# This class is the main class to implement your unit tests
# You have to extend and implement your test cases as described
# e.g
# --- MyTests.gd----------------------------------------------------------------
# extends GdUnitTestSuite
#
# func test_testCaseA():
#    assert_that("value").is_equal("value")
#
#-------------------------------------------------------------------------------
# For detailed instructions show http://gdUnit/plapla
################################################################################
class_name GdUnitTestSuite
extends Node

# This function is called before a test suite starts
# You can overwrite to prepare test data or initalizize necessary variables
func before() -> void:
	pass

# This function is called at least when a test suite is finished
# You can overwrite to cleanup data created during test running
func after() -> void:
	pass

# This function is called before a test case starts
# You can overwrite to prepare test case specific data
func before_test() -> void:
	pass

# This function is called after the test case is finished
# You can overwrite to cleanup your test case specific data
func after_test() -> void:
	pass

# === Tools ====================================================================
# Mapps Godot error number to a readable error message. See at ERROR
# https://docs.godotengine.org/de/stable/classes/class_@globalscope.html#enum-globalscope-error
func error_as_string(error_number :int) -> String:
	return GdUnitTools.error_as_string(error_number)

# A litle helper to auto freeing your created objects after test execution
func auto_free(obj):
	return GdUnitTools.register_auto_free(obj, get_meta("MEMORY_POOL"))

# Creates a new directory under the temporary directory *user://tmp*
# Useful for storing data during test execution. 
# The directory is automatically deleted after test suite execution
func create_temp_dir(relative_path :String) -> String:
	return GdUnitTools.create_temp_dir(relative_path)

# Deletes the temporary base directory
# Is called automatically after each execution of the test suite
func clean_temp_dir():
	GdUnitTools.clear_tmp()
	
# Creates a new file under the temporary directory *user://tmp* + <relative_path>
# with given name <file_name> and given file <mode> (default = File.WRITE)
# If success the returned File is automatically closed after the execution of the test suite
func create_temp_file(relative_path :String, file_name :String, mode :=File.WRITE) -> File:
	return GdUnitTools.create_temp_file(relative_path, file_name, mode)

# Reads a resource by given path <resource_path> into a PoolStringArray.
func resource_as_array(resource_path :String) -> PoolStringArray:
	return GdUnitTools.resource_as_array(resource_path)

# Reads a resource by given path <resource_path> and returned the content as String.
func resource_as_string(resource_path :String) -> String:
	return GdUnitTools.resource_as_string(resource_path)

# clears the debuger error list 
# PROTOTYPE!!!! Don't use it for now
func clear_push_errors() -> void:
	GdUnitTools.clear_push_errors()

# === Mocking  & Spy ===========================================================

# do return a default value for primitive types or null 
const RETURN_DEFAULTS = GdUnitMock.RETURN_DEFAULTS
# do call the real implementation
const CALL_REAL_FUNC = GdUnitMock.CALL_REAL_FUNC
# do return a default value for primitive types and a fully mocked value for Object types
# builds full deep mocked object
const RETURN_DEEP_STUB = GdUnitMock.RETURN_DEEP_STUB

# Creates a mock for given class name
func mock(clazz, mock_mode := RETURN_DEFAULTS):
	return GdUnitMockBuilder.build(clazz, mock_mode, get_meta("MEMORY_POOL"))

# Creates a spy on given object instance
func spy(instance):
	return GdUnitSpyBuilder.build(instance, get_meta("MEMORY_POOL"))

# Configures a return value for the specified function and used arguments.
func do_return(value) -> GdUnitMock:
	return GdUnitMock.new(value)

# Verifies certain behavior happened at least once or exact number of times
func verify(obj, times := 1):
	return GdUnitMock.verify(obj, times)

# Verifies no interactions is happen on this mock or spy
func verify_no_interactions(obj):
	return GdUnitMock.verify_no_interactions(obj)

# Verifies the given mock or spy has any unverified interaction.
func verify_no_more_interactions(obj, expect_result :int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitAssert:
	return GdUnitMock.verify_no_more_interactions(obj, expect_result)

# Resets the saved function call counters on a mock or spy
func reset(obj) -> void:
	GdUnitMock.reset(obj)

# === Argument matchers ========================================================
# Argument matcher to match any argument
static func any() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any()

# Argument matcher to match any boolean value
static func any_bool() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any_bool()

# Argument matcher to match any integer value
static func any_int() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any_int()

# Argument matcher to match any float value
static func any_float() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any_float()

# Argument matcher to match any string value
static func any_string() -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any_string()

# Argument matcher to match any instance of given class
static func any_class(clazz :Object) -> GdUnitArgumentMatcher:
	return GdUnitArgumentMatchers.any_class(clazz)

# === Asserts ==================================================================
func assert_that(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitAssert:
	match typeof(current):
		TYPE_BOOL:
			return assert_bool(current, expect_result)
		TYPE_INT:
			return assert_int(current, expect_result)
		TYPE_REAL:
			return assert_float(current, expect_result)
		TYPE_STRING:
			return assert_str(current, expect_result)
		TYPE_DICTIONARY:
			return assert_dict(current, expect_result)
		TYPE_ARRAY:
			return assert_array(current, expect_result)
		_:
			return assert_object(current, expect_result)

func assert_bool(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitBoolAssert:
	return GdUnitBoolAssertImpl.new(current, expect_result)

func assert_str(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitStringAssert:
	return GdUnitStringAssertImpl.new(current, expect_result)

func assert_int(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitIntAssert:
	return GdUnitIntAssertImpl.new(current, expect_result)

func assert_float(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFloatAssert:
	return GdUnitFloatAssertImpl.new(current, expect_result)

func assert_array(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitArrayAssert:
	return GdUnitArrayAssertImpl.new(current, expect_result)

func assert_dict(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitDictionaryAssert:
	return GdUnitDictionaryAssertImpl.new(current, expect_result)

static func assert_file(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFileAssert:
	return GdUnitFileAssertImpl.new(current, expect_result)

func assert_object(current, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitObjectAssert:
	return GdUnitObjectAssertImpl.new(current, get_meta("MEMORY_POOL"), expect_result)

func assert_result(current :Result, expect_result: int = GdUnitAssert.EXPECT_SUCCESS) -> GdUnitResultAssert:
	return GdUnitResultAssertImpl.new(current, get_meta("MEMORY_POOL"), expect_result)

static func assert_not_yet_implemented():
	GdUnitAssertImpl.new(null).test_fail()

# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdUnitFuncAssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitFuncAssertImpl.gd'


class TestValueProvider:
	var _max_iterations :int
	var _current_itteration := 0
	
	func _init(iterations := 0):
		_max_iterations = iterations
	
	func bool_value() -> bool:
		_current_itteration += 1
		if _current_itteration == _max_iterations:
			return true
		return false
	
	func int_value() -> int:
		return 0
	
	func float_value() -> float:
		return 0.0
	
	func string_value() -> String:
		return "value"
	
	func object_value() -> Object:
		return Resource.new()
	
	func array_value() -> Array:
		return []
	
	func dict_value() -> Dictionary:
		return {}
	
	func vec2_value() -> Vector2:
		return Vector2.ONE
	
	func vec3_value() -> Vector3:
		return Vector3.ONE
	
	func no_value() -> void:
		pass
	
	func unknown_value():
		return Vector3.ONE

class ValueProvidersWithArguments:
	
	func is_type(type :int) -> bool:
		return true
	
	func get_index(instance :Object, name :String) -> int:
		return 1
	
	func get_index2(instance :Object, name :String, recursive := false) -> int:
		return 1

class TestIterativeValueProvider:
	var _max_iterations :int
	var _current_itteration := 0
	var _inital_value
	var _final_value
	
	func _init(inital_value, iterations :int, final_value):
		_max_iterations = iterations
		_inital_value = inital_value
		_final_value = final_value
	
	func bool_value() -> bool:
		_current_itteration += 1
		if _current_itteration >= _max_iterations:
			return _final_value
		return _inital_value
	
	func int_value() -> int:
		_current_itteration += 1
		if _current_itteration >= _max_iterations:
			return _final_value
		return _inital_value
	
	func obj_value() -> Object:
		_current_itteration += 1
		if _current_itteration >= _max_iterations:
			return _final_value
		return _inital_value
		
	func has_type(type :int, recursive :bool = true) -> bool:
		_current_itteration += 1
		#yield(Engine.get_main_loop(), "idle_frame")
		if type == _current_itteration:
			return _final_value
		return _inital_value
	
	func yielded_value() -> int:
		_current_itteration += 1
		yield(Engine.get_main_loop(), "idle_frame")
		prints("yielded_value", _current_itteration)
		if _current_itteration >= _max_iterations:
			return _final_value
		return _inital_value
	
	func reset() -> void:
		_current_itteration = 0
	
	func iteration() -> int:
		return _current_itteration

func test_is_null(timeout = 2000) -> void:
	var value_provider := TestIterativeValueProvider.new(Reference.new(), 5, null)
	# without default timeout od 2000ms
	assert_func(value_provider, "obj_value").is_not_null()
	yield(assert_func(value_provider, "obj_value").is_null(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# with a timeout of 5s
	value_provider.reset()
	assert_func(value_provider, "obj_value").is_not_null()
	yield(assert_func(value_provider, "obj_value").wait_until(5000).is_null(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# failure case
	value_provider = TestIterativeValueProvider.new(Reference.new(), 1, Reference.new())
	yield(assert_func(value_provider, "obj_value", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_null(), "completed")\
		.has_failure_message("Expected: is null but timed out after 500ms")

func test_is_not_null(timeout = 2000) -> void:
	var value_provider := TestIterativeValueProvider.new(null, 5, Reference.new())
	# without default timeout od 2000ms
	assert_func(value_provider, "obj_value").is_null()
	yield(assert_func(value_provider, "obj_value").is_not_null(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# with a timeout of 5s
	value_provider.reset()
	assert_func(value_provider, "obj_value").is_null()
	yield(assert_func(value_provider, "obj_value").wait_until(5000).is_not_null(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# failure case
	value_provider = TestIterativeValueProvider.new(null, 1, null)
	yield(assert_func(value_provider, "obj_value", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_not_null(), "completed")\
		.has_failure_message("Expected: is not null but timed out after 500ms")

func test_is_true(timeout = 2000) -> void:
	var value_provider := TestIterativeValueProvider.new(false, 5, true)
	# without default timeout od 2000ms
	assert_func(value_provider, "bool_value").is_false()
	yield(assert_func(value_provider, "bool_value").is_true(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# with a timeout of 5s
	value_provider.reset()
	assert_func(value_provider, "bool_value").is_false()
	yield(assert_func(value_provider, "bool_value").wait_until(5000).is_true(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# failure case
	value_provider = TestIterativeValueProvider.new(false, 1, false)
	yield(assert_func(value_provider, "bool_value", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_true(), "completed")\
		.has_failure_message("Expected: is true but timed out after 500ms")

func test_is_false(timeout = 2000) -> void:
	var value_provider := TestIterativeValueProvider.new(true, 5, false)
	# without default timeout od 2000ms
	assert_func(value_provider, "bool_value").is_true()
	yield(assert_func(value_provider, "bool_value").is_false(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# with a timeout of 5s
	value_provider.reset()
	assert_func(value_provider, "bool_value").is_true()
	yield(assert_func(value_provider, "bool_value").wait_until(5000).is_false(), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# failure case
	value_provider = TestIterativeValueProvider.new(true, 1, true)
	yield(assert_func(value_provider, "bool_value", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_false(), "completed")\
		.has_failure_message("Expected: is false but timed out after 500ms")

func test_is_equal(timeout = 2000) -> void:
	var value_provider := TestIterativeValueProvider.new(42, 5, 23)
	# without default timeout od 2000ms
	assert_func(value_provider, "int_value").is_equal(42)
	yield(assert_func(value_provider, "int_value").is_equal(23), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# with a timeout of 5s
	value_provider.reset()
	assert_func(value_provider, "int_value").is_equal(42)
	yield(assert_func(value_provider, "int_value").wait_until(5000).is_equal(23), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# failing case
	value_provider = TestIterativeValueProvider.new(23, 1, 23)
	yield(assert_func(value_provider, "int_value", [], GdUnitAssert.EXPECT_FAIL).wait_until(1000).is_equal(25), "completed")\
		.has_failure_message("Expected: is equal '25' but timed out after 1s 0ms")

func test_is_not_equal(timeout = 2000) -> void:
	var value_provider := TestIterativeValueProvider.new(42, 5, 23)
	# without default timeout od 2000ms
	assert_func(value_provider, "int_value").is_equal(42)
	yield(assert_func(value_provider, "int_value").is_not_equal(42), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# with a timeout of 5s
	value_provider.reset()
	assert_func(value_provider, "int_value").is_equal(42)
	yield(assert_func(value_provider, "int_value").wait_until(5000).is_not_equal(42), "completed")
	assert_int(value_provider.iteration()).is_equal(5)
	
	# failing case
	value_provider = TestIterativeValueProvider.new(23, 1, 23)
	yield(assert_func(value_provider, "int_value", [], GdUnitAssert.EXPECT_FAIL).wait_until(1000).is_not_equal(23), "completed")\
		.has_failure_message("Expected: is not equal '23' but timed out after 1s 0ms")

func test_is_equal_wiht_func_arg(timeout = 1300) -> void:
	var value_provider := TestIterativeValueProvider.new(42, 10, 23)
	# without default timeout od 2000ms
	assert_func(value_provider, "has_type", [1]).is_equal(42)
	yield(assert_func(value_provider, "has_type", [10]).is_equal(23), "completed")
	assert_int(value_provider.iteration()).is_equal(10)
	
	# with a timeout of 5s
	value_provider.reset()
	assert_func(value_provider, "has_type", [1]).is_equal(42)
	yield(assert_func(value_provider, "has_type", [10]).wait_until(5000).is_equal(23), "completed")
	assert_int(value_provider.iteration()).is_equal(10)

# abort test after 500ms to fail
func test_timeout_and_assert_fails(timeout = 500) -> void:
	# disable temporary the timeout errors for this test
	discard_error_interupted_by_timeout()
	var value_provider := TestIterativeValueProvider.new(1, 10, 10)
	# wait longer than test timeout, the value will be never '42' 
	yield(assert_func(value_provider, "obj_value").wait_until(1000).is_equal(42), "completed")
	fail("The test must be interrupted after 500ms")

func timed_function() -> String:
	var color = Color.red
	yield(get_tree().create_timer(0.100), "timeout")
	color = Color.green
	yield(get_tree().create_timer(0.100), "timeout")
	color = Color.blue
	yield(get_tree().create_timer(0.100), "timeout")
	color = Color.black
	return color

func test_timer_yielded_function() -> void:
	yield(assert_func(self, "timed_function").is_equal(Color.black), "completed")
	# will be never red
	yield(assert_func(self, "timed_function").wait_until(500).is_not_equal(Color.red), "completed")
	# failure case
	yield(assert_func(self, "timed_function", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_equal(Color.red), "completed")\
		.has_failure_message("Expected: is equal '1,0,0,1' but timed out after 500ms")

func test_timer_yielded_function_timeout() -> void:
	yield(assert_func(self, "timed_function", [], GdUnitAssert.EXPECT_FAIL).wait_until(100).is_equal(Color.black), "completed")\
		.has_failure_message("Expected: is equal '0,0,0,1' but timed out after 100ms")

func yielded_function() -> String:
	var color = Color.red
	yield(get_tree(), "idle_frame")
	color = Color.green
	yield(get_tree(), "idle_frame")
	color = Color.blue
	yield(get_tree(), "idle_frame")
	return Color.black

func test_idle_frame_yielded_function() -> void:
	yield(assert_func(self, "yielded_function").is_equal(Color.black), "completed")
	yield(assert_func(self, "yielded_function", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_equal(Color.red), "completed")\
		.has_failure_message("Expected: is equal '1,0,0,1' but timed out after 500ms")

func test_has_failure_message() -> void:
	var value_provider := TestIterativeValueProvider.new(10, 1, 10)
	yield(assert_func(value_provider, "int_value", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_equal(42), "completed")\
		.has_failure_message("Expected: is equal '42' but timed out after 500ms")

func test_override_failure_message() -> void:
	var value_provider := TestIterativeValueProvider.new(10, 1, 20)
	yield(assert_func(value_provider, "int_value", [], GdUnitAssert.EXPECT_FAIL)\
		.override_failure_message("Custom failure message")\
		.wait_until(100)\
		.is_equal(42), "completed")\
		.has_failure_message("Custom failure message")

func test_invalid_function():
	yield(assert_func(self, "invalid_func_name", [], GdUnitAssert.EXPECT_FAIL)\
		.wait_until(100)\
		.is_equal(42), "completed")\
		.starts_with_failure_message("The function 'invalid_func_name' do not exists on instance '[Node:")

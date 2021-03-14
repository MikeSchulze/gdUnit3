# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitMockImpl

################################################################################
# internal mocking stuff
################################################################################
var _working_mode :String
var _assert_function_call_times :int = -1
var _do_return_value = null
var _saved_return_values := Dictionary()
var _saved_function_calls := Dictionary()


# self reference holder, use this kind of hack to store static function calls 
# it is important to manually free by '__release_double' otherwise it ends up in orphan instance
const _self := []

func __set_singleton():
	# store self need to mock static functions
	_self.append(self)

func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	_self.clear()

func __is_prepare_return_value() -> bool:
	return _do_return_value != null

func __save_function_return_value(args :Array):
	_saved_return_values[args] = _do_return_value
	_do_return_value = null
	return _saved_return_values[args]

func __save_function_call_times(args :Array):
	var times :int = _saved_function_calls.get(args, 0)
	_saved_function_calls[args] = times + 1

func __is_verify() -> bool:
	return _assert_function_call_times != -1

func __verify(args :Array, default_return_value):
	var times :int =  0
	var matcher := GdUnitArgumentMatchers.to_matcher(args)
	for key in _saved_function_calls.keys():
		if matcher.is_match(key):
			times += _saved_function_calls.get(key, 0)
	
	GdUnitIntAssertImpl.new(times, GdUnitAssert.EXPECT_SUCCESS).is_equal(_assert_function_call_times)
	_assert_function_call_times = -1
	return default_return_value

func __set_mode(mode :String):
	_working_mode = mode
	return self

func __do_return(value):
	_do_return_value = value
	return self

func __do_verify(times :int = 1):
	_assert_function_call_times = times
	return self

func __verify_no_interactions():
	if not _saved_function_calls.empty():
		GdUnitArrayAssertImpl.new([], GdUnitAssert.EXPECT_SUCCESS).contains(_saved_function_calls.keys())


# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitSpyImpl


var _instance_delegator
var _assert_function_call_times :int = -1
var _saved_function_calls = Dictionary()


# singleton holder
const _self := []

func __set_singleton(instance):
	# store self need to mock static functions
	_self.append(self)
	_instance_delegator = instance

func __save_function_call(args :Array):
	_saved_function_calls[args] = _saved_function_calls.get(args, 0) + 1

func __is_verify() -> bool:
	return _assert_function_call_times != -1

func __verify(args :Array):
	var times :int =  0
	var matcher := GdUnitArgumentMatchers.to_matcher(args)
	for key in _saved_function_calls.keys():
		if matcher.is_match(key):
			times += _saved_function_calls.get(key, 0)

	GdUnitIntAssertImpl.new(times, GdUnitAssert.EXPECT_SUCCESS).is_equal(_assert_function_call_times)
	_assert_function_call_times = -1

func __do_verify(times :int = 1):
	_assert_function_call_times = times
	return self 

func __verify_no_interactions():
	if not _saved_function_calls.empty():
		GdUnitArrayAssertImpl.new([], GdUnitAssert.EXPECT_SUCCESS).contains(_saved_function_calls.keys())

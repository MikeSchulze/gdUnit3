# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitSpyImpl


var _instance_delegator
var _assert_function_call_times :int = -1
var _saved_function_calls = Dictionary()
var _verified_functions := Array()


# self reference holder, use this kind of hack to store static function calls 
# it is important to manually free by '__release_double' otherwise it ends up in orphan instance
const _self := []

func __set_singleton(instance):
	# store self need to mock static functions
	_self.append(self)
	_instance_delegator = instance

func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	_self.clear()
	_instance_delegator = null

func __save_function_call(args :Array):
	_saved_function_calls[args] = _saved_function_calls.get(args, 0) + 1

func __reset() -> void:
	_saved_function_calls.clear()

func __is_verify() -> bool:
	return _assert_function_call_times != -1

func __verify(args :Array):
	var times :int =  0
	var matcher := GdUnitArgumentMatchers.to_matcher(args)
	for key in _saved_function_calls.keys():
		if matcher.is_match(key):
			times += _saved_function_calls.get(key, 0)
			# add as verified
			_verified_functions.append(key)

	GdUnitIntAssertImpl.new(times, GdUnitAssert.EXPECT_SUCCESS).is_equal(_assert_function_call_times)
	_assert_function_call_times = -1

func __do_verify(times :int = 1):
	_assert_function_call_times = times
	return self 

func __verify_no_interactions():
	var summary := Dictionary()
	if not _saved_function_calls.empty():
		for func_call in _saved_function_calls.keys():
			summary[func_call] = _saved_function_calls[func_call]
	return summary

func __verify_no_more_interactions() -> Dictionary:
	var summary := Dictionary()
	var called_functions :Array = _saved_function_calls.keys()
	if called_functions != _verified_functions:
		# collect the not verified functions
		var called_but_not_verified := called_functions.duplicate()
		for verified_function in _verified_functions:
			called_but_not_verified.erase(verified_function)
		
		for not_verified in called_but_not_verified:
			summary[not_verified] = _saved_function_calls[not_verified]
	return summary

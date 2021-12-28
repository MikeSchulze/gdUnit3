extends GdUnitTestSuite

var _current_iterations : Dictionary
var _expected_iterations: Dictionary

# a simple test fuzzer where provided a hard coded value set
class TestFuzzer extends Fuzzer:
	var _data := [0, 1, 2, 3, 4, 5, 6, 23, 8, 9]
	
	func next_value():
		return _data.pop_front()

func max_value() -> int:
	return 10

func min_value() -> int:
	return 1

func fuzzer() -> Fuzzer:
	return Fuzzers.rangei(min_value(), max_value())

func before():
	# define expected iteration count
	_expected_iterations = {
		"test_fuzzer_has_same_instance_peer_iteration" : 10,
		"test_fuzzer_iterations_default" : Fuzzer.ITERATION_DEFAULT_COUNT,
		"test_fuzzer_iterations_custom_value" : 234,
		"test_fuzzer_inject_value" : 100,
		"test_multiline_fuzzer_args": 10,
	}
	# inital values
	_current_iterations = {
		"test_fuzzer_has_same_instance_peer_iteration" : 0,
		"test_fuzzer_iterations_default" : 0,
		"test_fuzzer_iterations_custom_value" : 0,
		"test_fuzzer_inject_value" : 0,
		"test_multiline_fuzzer_args": 0,
	}

func after():
	for test_case in _expected_iterations.keys():
		var current = _current_iterations[test_case]
		var expected = _expected_iterations[test_case]
		
		assert_int(current).override_failure_message("Expecting %s itertions but is %s on test case %s" % [expected, current, test_case]).is_equal(expected)

var _fuzzer_instance_before : Fuzzer = null
func test_fuzzer_has_same_instance_peer_iteration(fuzzer=TestFuzzer.new(), fuzzer_iterations = 10):
	_current_iterations["test_fuzzer_has_same_instance_peer_iteration"] += 1
	if _fuzzer_instance_before != null:
		assert_that(fuzzer).is_same(_fuzzer_instance_before)
	_fuzzer_instance_before = fuzzer

func test_fuzzer_iterations_default(fuzzer := Fuzzers.rangei(-23, 22)):
	_current_iterations["test_fuzzer_iterations_default"] += 1

func test_fuzzer_iterations_custom_value(fuzzer := Fuzzers.rangei(-23, 22), fuzzer_iterations = 234, fuzzer_seed = 100):
	_current_iterations["test_fuzzer_iterations_custom_value"] += 1

func test_fuzzer_inject_value(fuzzer := Fuzzers.rangei(-23, 22), fuzzer_iterations = 100):
	_current_iterations["test_fuzzer_inject_value"] += 1
	assert_int(fuzzer.next_value()).is_between(-23, 22)

var expected_value := [-20, 6, -18, 8, 9, 9, 3, 16, -12, 0]
func test_fuzzer_inject_value_with_seed(fuzzer := Fuzzers.rangei(-23, 22), fuzzer_iterations = 10, fuzzer_seed = 187772):
	var iteration_index =  fuzzer.iteration_index()-1
	var current = fuzzer.next_value()
	var expected = expected_value[iteration_index]
	assert_int(iteration_index).is_between(0, 9).is_less(10)
	assert_int(current)\
		.override_failure_message("Expect value %s on test iteration %s\n but was %s" % [expected, iteration_index, current])\
		.is_equal(expected)

var expected_value_a := [-20, -18, 9, 3, -12, -21, -11, -13, -18, 7]
var expected_value_b := [40, 40, 40, 42, 38, 36, 39, 41, 37, 42]
func test_multiple_fuzzers_inject_value_with_seed(fuzzer_a := Fuzzers.rangei(-23, 22), fuzzer_b := Fuzzers.rangei(33, 44), fuzzer_iterations = 10, fuzzer_seed = 187772):
	var iteration_index_a =  fuzzer_a.iteration_index()-1
	var current_a = fuzzer_a.next_value()
	var expected_a = expected_value_a[iteration_index_a]
	assert_int(iteration_index_a).is_between(0, 9).is_less(10)
	assert_int(current_a).is_between(-23, 22)
	assert_int(current_a)\
		.override_failure_message("Expect value %s on test iteration %s\n but was %s" % [expected_a, iteration_index_a, current_a])\
		.is_equal(expected_a)
	
	var iteration_index_b =  fuzzer_b.iteration_index()-1
	var current_b = fuzzer_b.next_value()
	var expected_b = expected_value_b[iteration_index_b]
	assert_int(iteration_index_b).is_between(0, 9).is_less(10)
	assert_int(current_b).is_between(33, 44)
	assert_int(current_b)\
		.override_failure_message("Expect value %s on test iteration %s\n but was %s" % [expected_b, iteration_index_b, current_b])\
		.is_equal(expected_b)

func test_fuzzer_error_after_eight_iterations(fuzzer=TestFuzzer.new(), fuzzer_iterations = 10):
	# should fail after 8 iterations
	if fuzzer.iteration_index() == 8:
		assert_int(fuzzer.next_value(), GdUnitAssert.EXPECT_FAIL) \
			.is_between(0, 9) \
			.has_failure_message("Expecting:\n '23'\n in range between\n '0' <> '9'")
	else:
		assert_int(fuzzer.next_value()).is_between(0, 9)

func test_fuzzer_custom_func(fuzzer=fuzzer()):
	assert_int(fuzzer.next_value()).is_between(1, 10)

func test_multiline_fuzzer_args(
	fuzzer := Fuzzers.rangev2(Vector2(-47, -47), Vector2(47, 47)),
	nfuzzer := Fuzzers.rangei(0, 9),
	fuzzer_iterations = 23):
		_current_iterations["test_multiline_fuzzer_args"] += 1

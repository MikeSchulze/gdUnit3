extends GdUnitTestSuite

var _current_test_case: String = ""
var _test_case_iterations: int = 0
var _expected_iterations: Dictionary
var _collect_values_by_seed := Array()

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
	_expected_iterations = {
		"test_fuzzer_iterations_default" : Fuzzer.ITERATION_DEFAULT_COUNT,
		"test_fuzzer_iterations_custom_value" : 234,
	}

func before_test():
	_current_test_case = ""
	_test_case_iterations = 0
	_collect_values_by_seed = []
	
func after_test():
	if _expected_iterations.has(_current_test_case):
		assert_int(_test_case_iterations).is_equal(_expected_iterations.get(_current_test_case))

var _fuzzer_instance_before : Fuzzer = null
func test_fuzzer_has_same_instance_peer_iteration(fuzzer=TestFuzzer.new(), fuzzer_iterations = 10):
	if _fuzzer_instance_before != null:
		assert_that(fuzzer).is_same(_fuzzer_instance_before)
	_fuzzer_instance_before = fuzzer

func test_fuzzer_iterations_default(fuzzer := Fuzzers.rangei(-23, 22)):
	_test_case_iterations += 1
	_current_test_case = "test_fuzzer_iterations_default"

func test_fuzzer_iterations_custom_value(fuzzer := Fuzzers.rangei(-23, 22), fuzzer_iterations = 234, fuzzer_seed = 100):
	_test_case_iterations += 1
	_current_test_case = "test_fuzzer_iterations_custom_value"

func test_fuzzer_inject_value(fuzzer := Fuzzers.rangei(-23, 22), fuzzer_iterations = 100):
	assert_int(fuzzer.next_value()).is_in_range(-23, 22)

func test_fuzzer_inject_value_with_seed(fuzzer := Fuzzers.rangei(-23, 22), fuzzer_iterations = 10, fuzzer_seed = 187772):
	_test_case_iterations += 1
	# collect all generated values
	_collect_values_by_seed.append(fuzzer.next_value())
	# finally check after 10 iterations
	if _test_case_iterations == 10:
		# with same seed we expect always the same values generated
		assert_array(_collect_values_by_seed).contains_exactly([-20, 6, -18, 8, 9, 9, 3, 16, -12, 0])

func test_fuzzer_error_after_eight_iterations(fuzzer=TestFuzzer.new(), fuzzer_iterations = 10):
	_test_case_iterations += 1
	# should fail after 8 iterations
	if _test_case_iterations == 8:
		assert_int(fuzzer.next_value(), GdUnitAssert.EXPECT_FAIL) \
			.is_in_range(0, 9) \
			.has_error_message("Expecting:\n '23'\n in range between\n '0' <> '9'")
	else:
		assert_int(fuzzer.next_value()).is_in_range(0, 9)

func test_fuzzer_custom_func(fuzzer=fuzzer()):
	assert_int(fuzzer.next_value()).is_in_range(1, 10)

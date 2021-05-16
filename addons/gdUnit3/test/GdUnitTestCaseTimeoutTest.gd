# this test suite simulates long running test cases
extends GdUnitTestSuite

var _timer_start = 0
const SECOND:int = 1000
const MINUTE:int = SECOND*60

var _before_arg
var _test_arg

func before():
	# use some variables to test clone test suite works as expected
	_before_arg = "---before---"

func before_test():
	# set failing test to success if failed by timeout
	discard_error_interupted_by_timeout()
	_timer_start = OS.get_system_time_msecs()
	_test_arg = "abc"

# without custom timeout should execute the complete test
func test_timeout_after_test_completes():
	assert_str(_before_arg).is_equal("---before---")
	var counter := 0
	yield(get_tree().create_timer(1.0), "timeout")
	prints("A","1s")
	counter += 1
	yield(get_tree().create_timer(1.0), "timeout")
	prints("A","2s")
	counter += 1
	yield(get_tree().create_timer(1.0), "timeout")
	prints("A","3s")
	counter += 1
	yield(get_tree().create_timer(2.0), "timeout")
	prints("A","5s")
	counter += 2
	prints("A","end test test_timeout_after_test_completes")
	assert_int(counter).is_equal(5)

# set test timeout to 2s
func test_timeout_2s(timeout=2000):
	assert_str(_before_arg).is_equal("---before---")
	prints("B", "0s")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("B", "1s")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("B", "2s")
	yield(get_tree().create_timer(1.0), "timeout")
	# this line should not reach if timeout aborts the test case after 2s
	assert_bool(true).as_error_message("The test case must be interupted by a timeout after 2s").is_false()
	prints("B", "3s")
	prints("B", "end")

# set test timeout to 4s
func test_timeout_4s(timeout=4000):
	assert_str(_before_arg).is_equal("---before---")
	prints("C", "0s")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("C", "1s")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("C", "2s")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("C", "3s")
	yield(get_tree().create_timer(4.0), "timeout")
	# this line should not reach if timeout aborts the test case after 4s
	assert_bool(true).as_error_message("The test case must be interupted by a timeout after 4s").is_false()
	prints("C", "7s")
	prints("C", "end")

func test_timeout_single_yield_wait(timeout=3000):
	assert_str(_before_arg).is_equal("---before---")
	prints("D", "0s")
	yield(get_tree().create_timer(6.0), "timeout")
	prints("D", "6s")
	# this line should not reach if timeout aborts the test case after 3s
	assert_bool(true).as_error_message("The test case must be interupted by a timeout after 3s").is_false()
	prints("D", "end test test_timeout")

func test_timeout_long_running_test_abort(timeout=4000):
	assert_str(_before_arg).is_equal("---before---")
	prints("E", "0s")
	var start_time := OS.get_system_time_msecs()
	var sec_start_time := OS.get_system_time_msecs()
	var start := LocalTime.now()
	
	# simulate long running function
	while true:
		var x = 1
		var elapsed_time := OS.get_system_time_msecs() - start_time
		
		var sec_time = OS.get_system_time_msecs() - sec_start_time
		
		yield(get_tree(), "idle_frame")
		if sec_time > 1000:
			sec_start_time = OS.get_system_time_msecs()
			prints("E", start.elapsed_since())
		
		# exit while after 10s
		if elapsed_time > 1000 * 10:
			break
	
	# this line should not reach if timeout aborts the test case after 4s
	assert_bool(true).as_error_message("The test case must be abort interupted by a timeout 4s").is_false()
	prints("F", "end test test_timeout")

func test_timeout_fuzzer(fuzzer := Fuzzers.rangei(-23, 22), timeout=2000):
	var value = fuzzer.next_value()
	# wait each iteration 200ms 
	yield(get_tree().create_timer(0.200), "timeout")

	# we expects the test is interupped after 10 iterations because each test takes 200ms
	# and the test should not longer run than 2000ms
	assert_int(fuzzer.iteration_index())\
		.as_error_message("The test must be interupted after around 10 iterations")\
		.is_less_equal(10)

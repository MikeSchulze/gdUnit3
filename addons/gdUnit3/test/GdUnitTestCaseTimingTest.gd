# this test suite simulates long running test cases
extends GdUnitTestSuite

var _timer_start = 0
const SECOND:int = 1000
const MINUTE:int = SECOND*60

func before_test():
	_timer_start = OS.get_system_time_msecs()

func test_fast():
	var timer_start = OS.get_system_time_msecs()
	yield(get_tree().create_timer(0.200), "timeout")
	# subtract an offset of 100ms because the time is not accurate
	assert_int(OS.get_system_time_msecs()-timer_start).is_between(100, 300)

func test_2s():
	_timer_start = OS.get_system_time_msecs()
	yield(get_tree().create_timer(2.0), "timeout")
	# subtract an offset of 100ms because the time is not accurate
	assert_int(OS.get_system_time_msecs()-_timer_start).is_between(2*SECOND-100, 2*SECOND+100)

func test_1m():
	yield(get_tree().create_timer(60.0), "timeout")
	assert_int(OS.get_system_time_msecs()-_timer_start).is_greater_equal(MINUTE-100)

func test_multi_yielding():
	prints("test_yielding")
	yield(get_tree(), "idle_frame")
	prints("4")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("3")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("2")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("1")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("Go")
	assert_int(OS.get_system_time_msecs()-_timer_start).is_greater_equal(4*(SECOND-50))

func test_multi_yielding_with_fuzzer(fuzzer := Fuzzers.rangei(0, 1000), fuzzer_iterations = 10):
	prints("test iteration %d" % fuzzer.iteration_index())
	prints("4")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("3")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("2")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("1")
	yield(get_tree().create_timer(1.0), "timeout")
	prints("Go")
	assert_int(OS.get_system_time_msecs()-_timer_start).is_greater_equal(3900*fuzzer.iteration_index())
	if fuzzer.iteration_index() == 10:
		# elapsed time must be fuzzer_iterations times * 4s = 40s
		assert_int(OS.get_system_time_msecs()-_timer_start).is_greater_equal(4000*fuzzer_iterations)

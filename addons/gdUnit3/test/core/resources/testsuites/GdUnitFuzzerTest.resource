# this test suite simulates long running test cases
extends GdUnitTestSuite


var _stack : Array

func before():
	# init the stack
	_stack = []

func before_test():
	# clean the stack before every test run
	_stack.clear()


func test_multi_yielding_with_fuzzer(fuzzer := Fuzzers.rangei(0, 1000), fuzzer_iterations = 10):
	# verify the used stack is cleaned by 'before_test'
	assert_array(_stack).is_empty()
	_stack.push_back(1)

	prints("test iteration %d" % fuzzer.iteration_index())
	prints("4")
	yield(get_tree(), "idle_frame")
	prints("3")
	yield(get_tree(), "idle_frame")
	prints("2")
	yield(get_tree(), "idle_frame")
	prints("1")
	yield(get_tree(), "idle_frame")
	prints("Go")

func test_multi_yielding_with_fuzzer_fail_after_3_iterations(fuzzer := Fuzzers.rangei(0, 1000), fuzzer_iterations = 10):
	prints("test iteration %d" % fuzzer.iteration_index())
	# should never be greater than 3 because we interuppted after three iterations
	assert_int(fuzzer.iteration_index()).is_less_equal(3)
	prints("4")
	yield(get_tree(), "idle_frame")
	prints("3")
	yield(get_tree(), "idle_frame")
	prints("2")
	yield(get_tree(), "idle_frame")
	prints("1")
	yield(get_tree(), "idle_frame")
	prints("Go")
	if fuzzer.iteration_index() >= 3:
		assert_bool(true).is_false()

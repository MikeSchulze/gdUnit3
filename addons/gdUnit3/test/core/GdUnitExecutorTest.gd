# GdUnit generated TestSuite
class_name GdUnitExecutorTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitExecutor.gd'

var _executor :GdUnitExecutor
var _events :Array = Array()

func before():
	_executor = GdUnitExecutor.new(true)
	Engine.get_main_loop().root.add_child(_executor)
	_executor.connect("send_event_debug", self, "_on_executor_event")

func resource(resource_path :String) -> GdUnitTestSuite:
	return GdUnitTestResourceLoader.load_test_suite(resource_path)

func _on_executor_event(event :GdUnitEvent) -> void:
	_events.append(event)

func execute(test_suite :GdUnitTestSuite, enable_orphan_detection := true):
	yield(get_tree(), "idle_frame")
	_events.clear()
	_executor._memory_pool.configure(enable_orphan_detection)
	var fs = _executor.execute(test_suite)
	if GdUnitTools.is_yielded(fs):
		yield(fs, "completed" )
	return _events

func filter_failures(events :Array) -> Array:
	var filtered_events := Array()
	for e in events:
		var event :GdUnitEvent = e
		prints(event)
		if event.is_failed():
			filtered_events.append(event)
	return filtered_events

func flating_message(message :String) -> String:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.parse_bbcode(message)
	var current_error := rtl.get_text()
	rtl.free()
	return current_error.replace("\n", "").replace("\r", "")

func assert_event_reports(events :Array, reports1 :Array, reports2 :Array, reports3 :Array, reports4 :Array, reports5 :Array, reports6 :Array) -> void:
	var expected_reports := [reports1, reports2, reports3, reports4, reports5, reports6]
	for event_index in events.size():
		var current :Array = events[event_index].reports()
		var expected = expected_reports[event_index]
		if expected.empty():
			for m in current.size():
				assert_str(flating_message(current[m].message())).is_empty()
		
		for m in expected.size():
			if m < current.size():
				assert_str(flating_message(current[m].message())).is_equal(expected[m])
			else:
				assert_str("<N/A>").is_equal(expected[m])

func assert_event_list(events :Array, suite_name :String) -> void:
	assert_array(events).has_size(6).extractv(
		extr("type"), extr("suite_name"), extr("test_name"), extr("total_count"))\
		.contains_exactly([
			tuple(GdUnitEvent.TESTSUITE_BEFORE, suite_name, "before", 2),
			tuple(GdUnitEvent.TESTCASE_BEFORE, suite_name, "test_case1", 0),
			tuple(GdUnitEvent.TESTCASE_AFTER, suite_name, "test_case1", 0),
			tuple(GdUnitEvent.TESTCASE_BEFORE, suite_name, "test_case2", 0),
			tuple(GdUnitEvent.TESTCASE_AFTER, suite_name, "test_case2", 0),
			tuple(GdUnitEvent.TESTSUITE_AFTER, suite_name, "after", 0),
		])

func assert_event_counters(events :Array) -> GdUnitArrayAssert:
	return assert_array(events).extractv(extr("type"), extr("error_count"), extr("failed_count"), extr("orphan_nodes"))

func assert_event_states(events :Array) -> GdUnitArrayAssert:
	return assert_array(events).extractv(extr("test_name"), extr("is_success"), extr("is_warning"), extr("is_failed"), extr("is_error"))

func test_execute_success() -> void:
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteAllStagesSuccess.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteAllStagesSuccess")
	# verify all counters are zero / no errors, failures, orphans
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 0, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		tuple("after", true, false, false, false),
	])
	# all success no reports expected
	assert_event_reports(events, [], [], [], [], [], [])

func test_execute_failure_on_stage_before() -> void:
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailOnStageBefore.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteFailOnStageBefore")
	# we expect the testsuite is failing on stage 'before()' and commits one failure
	# reported finally at TESTSUITE_AFTER event
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		# report failure failed_count = 1
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 1, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		# report suite is not success, is failed
		tuple("after", false, false, true, false),
	])
	# one failure at before()
	assert_event_reports(events, 
		[], 
		[], 
		[], 
		[], 
		[], 
		["failed on before()"])

func test_execute_failure_on_stage_after() -> void:
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailOnStageAfter.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteFailOnStageAfter")
	# we expect the testsuite is failing on stage 'before()' and commits one failure
	# reported finally at TESTSUITE_AFTER event
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		# report failure failed_count = 1
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 1, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		# report suite is not success, is failed
		tuple("after", false, false, true, false),
	])
	# one failure at after()
	assert_event_reports(events,
		[],
		[], 
		[],
		[], 
		[],
		["failed on after()"])

func test_execute_failure_on_stage_before_test() -> void:
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailOnStageBeforeTest.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteFailOnStageBeforeTest")
	# we expect the testsuite is failing on stage 'before_test()' and commits one failure on each test case
	# because is in scope of test execution
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# failure is count to the test
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# failure is count to the test
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 0),
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 0, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case1", false, false, true, false),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", false, false, true, false),
		# report suite is not success, is failed
		tuple("after", false, false, true, false),
	])
	# before_test() failure report is append to each test
	assert_event_reports(events,
		[],
		[], 
		# verify failure report is append to 'test_case1'
		["failed on before_test()"],
		[], 
		# verify failure report is append to 'test_case2'
		["failed on before_test()"],
		[])

func test_execute_failure_on_stage_after_test() -> void:
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailOnStageAfterTest.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteFailOnStageAfterTest")
	# we expect the testsuite is failing on stage 'after_test()' and commits one failure on each test case
	# because is in scope of test execution
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# failure is count to the test
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# failure is count to the test
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 0),
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 0, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case1", false, false, true, false),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", false, false, true, false),
		# report suite is not success, is failed
		tuple("after", false, false, true, false),
	])
	# 'after_test' failure report is append to each test
	assert_event_reports(events,
		[],
		[], 
		# verify failure report is append to 'test_case1'
		["failed on after_test()"],
		[], 
		# verify failure report is append to 'test_case2'
		["failed on after_test()"],
		[])

func test_execute_failure_on_stage_test_case1() -> void:
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailOnStageTestCase1.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteFailOnStageTestCase1")
	# we expect the test case 'test_case1' is failing  and commits one failure
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# test has one failure
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 0, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case1", false, false, true, false),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		# report suite is not success, is failed
		tuple("after", false, false, true, false),
	])
	# only 'test_case1' reports a failure
	assert_event_reports(events,
		[],
		[], 
		# verify failure report is append to 'test_case1'
		["failed on test_case1()"], 
		[], 
		[], 
		[])

func test_execute_failure_on_muliple_stages() -> void:
	# this is a more complex failure state, we expect to find multipe failures on different stages
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailOnMultipeStages.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteFailOnMultipeStages")
	# we expect failing on multiple stages
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# the first test has two failures plus one from 'before_test'
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 3, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# the second test has no failures but one from 'before_test'
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 0),
		# and one failure is on stage 'after' found
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 1, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		tuple("test_case1", false, false, true, false),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", false, false, true, false),
		# report suite is not success, is failed
		tuple("after", false, false, true, false),
	])
	# only 'test_case1' reports a 'real' failures plus test setup stage failures
	assert_event_reports(events,
		[],
		[],
		# verify failure reports to 'test_case1'
		["failed on before_test()", "failed 1 on test_case1()", "failed 2 on test_case1()"], 
		[],
		# verify failure reports to 'test_case2'
		["failed on before_test()"],
		# and one failure detected at stage 'after'
		["failed on after()"])

# GD-63
func test_execute_failure_and_orphans() -> void:
	# this is a more complex failure state, we expect to find multipe orphans on different stages
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailAndOrpahnsDetected.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed")
	# verify basis infos
	assert_event_list(events, "TestSuiteFailAndOrpahnsDetected")
	# we expect failing on multiple stages
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# the first test ends with a warning and in summ 5 orphans detected
		# 2 from stage 'before_test' + 3 from test itself
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 5),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# the second test ends with a one failure and in summ 6 orphans detected
		# 2 from stage 'before_test' + 4 from test itself
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 6),
		# and one orphan detected from stage 'before'
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 0, 1),
	])
	# is_success, is_warning, is_failed, is_error
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		# test case has only warnings
		tuple("test_case1", false, true, false, false),
		tuple("test_case2", true, false, false, false),
		# test case has failures and warnings
		tuple("test_case2", false, true, true, false),
		# report suite is not success, has warnings and failures
		tuple("after", false, true, true, false),
	])
	# only 'test_case1' reports a 'real' failures plus test setup stage failures
	assert_event_reports(events,
		[],
		[],
		# ends with warnings
		["WARNING: Detected <3> orphan nodes during test execution!",
		 "WARNING: Detected <2> orphan nodes during test setup! Check before_test() and after_test()!"],
		[],
		# ends with failure and warnings 
		["WARNING: Detected <4> orphan nodes during test execution!",
		 "faild on test_case2()",
		 "WARNING: Detected <2> orphan nodes during test setup! Check before_test() and after_test()!"],
		# and one failure detected at stage 'after'
		["WARNING: Detected <1> orphan nodes during test suite setup stage! Check before() and after()!"])

# GD-62
func test_execute_failure_and_orphans_report_orphan_disabled() -> void:
	# this is a more complex failure state, we expect to find multipe orphans on different stages
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteFailAndOrpahnsDetected.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution whit disabled orphan detection
	var events = yield(execute(test_suite, false), "completed")
	# verify basis infos
	assert_event_list(events, "TestSuiteFailAndOrpahnsDetected")
	# we expect failing on multiple stages, no orphans reported
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# one failure
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 1, 0),
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 0, 0),
	])
	# is_success, is_warning, is_failed, is_error
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		# test case has success
		tuple("test_case1", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		# test case has a failure
		tuple("test_case2", false, false, true, false),
		# report suite is not success, has warnings and failures
		tuple("after", false, false, true, false),
	])
	# only 'test_case1' reports a failure, orphans are not reported
	assert_event_reports(events,
		[],
		[],
		[],
		[],
		# ends with a failure
		["faild on test_case2()"],
		[])

# GD-66
func test_execute_error_on_test_timeout() -> void:
	# this tests a timeout on a test case reported as error
	var test_suite := resource("res://addons/gdUnit3/test/core/resources/testsuites/TestSuiteErrorOnTestTimeout.resource")
	# verify all test cases loaded
	assert_array(test_suite.get_children()).extract("get_name").contains_exactly(["test_case1", "test_case2"])
	# simulate test suite execution
	var events = yield(execute(test_suite), "completed" )
	# verify basis infos
	assert_event_list(events, "TestSuiteErrorOnTestTimeout")
	# we expect failing on multiple stages
	assert_event_counters(events).contains_exactly([
		tuple(GdUnitEvent.TESTSUITE_BEFORE, 0, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# the first test has two failures plus one from 'before_test'
		tuple(GdUnitEvent.TESTCASE_AFTER, 1, 0, 0),
		tuple(GdUnitEvent.TESTCASE_BEFORE, 0, 0, 0),
		# the second test has no failures but one from 'before_test'
		tuple(GdUnitEvent.TESTCASE_AFTER, 0, 0, 0),
		# and one failure is on stage 'after' found
		tuple(GdUnitEvent.TESTSUITE_AFTER, 0, 0, 0),
	])
	assert_event_states(events).contains_exactly([
		tuple("before", true, false, false, false),
		tuple("test_case1", true, false, false, false),
		# testcase ends with a timeout error
		tuple("test_case1", false, false, false, true),
		tuple("test_case2", true, false, false, false),
		tuple("test_case2", true, false, false, false),
		# report suite is not success, is error
		tuple("after", false, false, false, true),
	])
	# 'test_case1' reports a error triggered by test timeout
	assert_event_reports(events,
		[],
		[],
		# verify error reports to 'test_case1'
		["Test timed out suite_after 2s 0ms"],
		[],
		[],
		[])

class_name GdUnitExecutor
extends Node

signal send_event

var _testsuite_timer :LocalTime
var _testcase_timer :LocalTime
var _testrun_timer :LocalTime

# monitors
var _mem_monitor_testrun := GdUnitMemMonitor.new("Test-Execution")
var _mem_monitor_testsuite := GdUnitMemMonitor.new("Test-Suite")
var _mem_monitor_testcase := GdUnitMemMonitor.new("Test-Case")

onready var _push_error_monitor := PushErrorMonitor.new()
var _report_errors_enabled :bool

var _total_test_orphan_nodes :int
var _total_test_warnings :int
var _total_test_failed :int

var _reports :Array = Array()

var _event_handler :SignalHandler
var _test_run_state :GDScriptFunctionState
var _with_yielding := true
var _fail_fast := false

var _x = GdUnitArgumentMatchers.new()

func _ready():
	_event_handler = GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)
	if _event_handler != null:
		_event_handler.register_on_test_reports(self, "_event_test_report")
	_report_errors_enabled = GdUnitSettings.is_report_push_errors()

# disable yielding for CLI tool where results in unneccesary waits
# the default yield is only set when the executer is runnung in context of client/server
func disable_default_yield():
	_with_yielding = false

func fail_fast(enabled :bool) -> void:
	_fail_fast = enabled

func before(test_suite :GdUnitTestSuite, total_count :int) -> GDScriptFunctionState:
	emit_signal("send_event", GdUnitEvent.new()\
		.before(test_suite.get_script().resource_path, test_suite.get_name(), total_count))
	_testsuite_timer = LocalTime.now()
	_total_test_orphan_nodes = 0
	_total_test_failed = 0
	_total_test_warnings = 0
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTSUITE)
	_mem_monitor_testsuite.start()
	if not test_suite.is_skipped():
		var fstate = test_suite.before()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
	GdUnitTools.run_auto_close()
	return null

func after(test_suite :GdUnitTestSuite) -> GDScriptFunctionState:
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTSUITE)
	var is_skipped := test_suite.is_skipped()
	var skip_count := test_suite.get_child_count()
	if not is_skipped:
		skip_count = 0
		var fstate = test_suite.after()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
	GdUnitTools.run_auto_free(GdUnitTools.MEMORY_POOL_TESTSUITE)
	GdUnitTools.run_auto_close()
	GdUnitTools.clear_tmp()
	_mem_monitor_testsuite.stop()
	_mem_monitor_testsuite.subtract(_total_test_orphan_nodes)

	var test_warnings := _total_test_warnings != 0
	var test_failed := _total_test_failed != 0
	var test_errors := false
	var orphan_nodes := _mem_monitor_testsuite.orphan_nodes()
	# create report if orphan nodes detected
	if orphan_nodes > 0:
		_reports.push_front(GdUnitReport.new() \
			.create(GdUnitReport.WARN, 1, GdAssertMessages.orphan_detected_on_before(orphan_nodes)))
	
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: orphan_nodes,
		GdUnitEvent.ELAPSED_TIME: _testsuite_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: test_warnings,
		GdUnitEvent.ERRORS: test_errors,
		GdUnitEvent.FAILED: test_failed,
		GdUnitEvent.FAILED_COUNT: _total_test_failed,
		GdUnitEvent.SKIPPED_COUNT: skip_count,
		GdUnitEvent.SKIPPED: is_skipped
	}
	emit_signal("send_event", GdUnitEvent.new().after(test_suite.get_script().resource_path, test_suite.get_name(), statistics, _reports.duplicate()))
	_reports.clear()
	return null

func before_test(test_suite :GdUnitTestSuite, test_case :_TestCase) -> GDScriptFunctionState:
	_testcase_timer = LocalTime.now()
	_reports.clear()
	emit_signal("send_event", GdUnitEvent.new()\
		.beforeTest(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name()))
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTCASE)
	_mem_monitor_testcase.start()
	if not test_case.is_skipped():
		var fstate = test_suite.before_test()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
	GdUnitTools.run_auto_close()
	return null

func after_test(test_suite :GdUnitTestSuite, test_case :_TestCase) -> GDScriptFunctionState:
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTCASE)
	if not test_case.is_skipped():
		var fstate = test_suite.after_test()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
	GdUnitTools.run_auto_free(GdUnitTools.MEMORY_POOL_TESTCASE)
	_mem_monitor_testcase.stop()
	_mem_monitor_testcase.subtract(_mem_monitor_testrun.orphan_nodes())

	var test_warnings := false
	var test_failed := not _reports.empty()
	var test_errors := test_case.is_interupted() and not test_case.is_expect_interupted()
	var orphan_nodes = _mem_monitor_testcase.orphan_nodes()
	# create report if  orphan nodes detected
	if orphan_nodes > 0:
		test_warnings = true
		_total_test_warnings += 1
		_reports.push_front(GdUnitReport.new() \
			.create(GdUnitReport.WARN, test_case.line_number(), GdAssertMessages.orphan_detected_on_before_test(orphan_nodes)))
	
	_total_test_orphan_nodes += _mem_monitor_testcase.orphan_nodes()
	_total_test_failed += test_failed as int
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: orphan_nodes,
		GdUnitEvent.ELAPSED_TIME: _testcase_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: test_warnings,
		GdUnitEvent.ERRORS: test_errors,
		GdUnitEvent.FAILED: test_failed,
		GdUnitEvent.SKIPPED: test_case.is_skipped(),
		GdUnitEvent.SKIPPED_COUNT: int(test_case.is_skipped()),
	}
	
	emit_signal("send_event", GdUnitEvent.new()\
		.afterTest(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name(), statistics, _reports.duplicate()))
	_reports.clear()
	return null

func _before_test_run(test_suite :GdUnitTestSuite, test_case :_TestCase):
	_testrun_timer = LocalTime.now()
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTRUN)
	_mem_monitor_testrun.start()
	
	emit_signal("send_event", GdUnitEvent.new()\
		.testrun_before(test_suite.get_name(), test_case.get_name()))
	
	test_case.generate_seed()

func _after_test_run(test_suite :GdUnitTestSuite, test_case :_TestCase):
	GdUnitTools.run_auto_free(GdUnitTools.MEMORY_POOL_TESTRUN)
	_mem_monitor_testrun.stop()
	var test_warnings := false
	var test_failed := not _reports.empty()
	var test_errors := test_case.is_interupted() and not test_case.is_expect_interupted()
	var orphan_nodes := _mem_monitor_testrun.orphan_nodes()
	_total_test_orphan_nodes += orphan_nodes
	_total_test_failed += test_failed as int
	# create report if orphan nodes detected
	if orphan_nodes > 0:
		test_warnings = true
		_total_test_warnings += 1
		_reports.push_front(GdUnitReport.new() \
			.create(GdUnitReport.WARN, test_case.line_number(), GdAssertMessages.orphan_detected_on_test(orphan_nodes) ))
	
	# send test report 
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: orphan_nodes,
		GdUnitEvent.ELAPSED_TIME: _testrun_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: test_warnings,
		GdUnitEvent.ERRORS: test_errors,
		GdUnitEvent.FAILED: test_failed,
		GdUnitEvent.SKIPPED: test_case.is_skipped(),
	}
	emit_signal("send_event", GdUnitEvent.new()\
		.testrun_after(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name(), statistics, _reports.duplicate()))
	_reports.clear()

func execute_test_case(test_suite :GdUnitTestSuite, test_case :_TestCase) -> GDScriptFunctionState:
	_test_run_state = before_test(test_suite, test_case)
	if GdUnitTools.is_yielded(_test_run_state):
		yield(_test_run_state, "completed")
		_test_run_state = null
	var fuzzer := create_fuzzer(test_suite, test_case)
	_before_test_run(test_suite, test_case)
	if not test_case.is_skipped():
		if not fuzzer:
			_test_run_state = test_case.execute()
			# is yielded than wait for completed
			if GdUnitTools.is_yielded(_test_run_state):
				yield(_test_run_state, "completed")
		else:
			for iteration in fuzzer.iteration_limit():
				if _with_yielding:
					# give main thread time to sync to prevent network timeouts
					yield(get_tree(), "idle_frame")
				# interrupt at first failure
				if _reports.size() > 0:
					var report :GdUnitReport = _reports.pop_front()
					_reports.push_front(GdUnitReport.new() \
							.create(GdUnitReport.INTERUPTED, report.line_number(), GdAssertMessages.fuzzer_interuped(iteration-1, report.message())))
					break
				fuzzer._iteration_index += 1
				_test_run_state = test_case.execute(fuzzer)
				# is yielded than wait for completed
				if GdUnitTools.is_yielded(_test_run_state):
					yield(_test_run_state, "completed")
				if test_case.is_interupted():
					break
	
	if test_case.is_interupted() and not test_case.is_expect_interupted():
		_reports.push_front(GdUnitReport.new() \
				.create(GdUnitReport.INTERUPTED, test_case.line_number(), "Test timed out after %s" % LocalTime.elapsed(test_case.timeout())))
	
	if is_instance_valid(test_suite.__scene_runner):
		test_suite.__scene_runner.free()
		# give runner time to finallize
		yield(get_tree(), "idle_frame")
		test_suite.__scene_runner = null
	
	_test_run_state = _after_test_run(test_suite, test_case)
	if GdUnitTools.is_yielded(_test_run_state):
		yield(_test_run_state, "completed")
		_test_run_state = null
	_test_run_state = after_test(test_suite, test_case)
	if GdUnitTools.is_yielded(_test_run_state):
		yield(_test_run_state, "completed")
		_test_run_state = null
	return _test_run_state

func execute(test_suite :GdUnitTestSuite) -> GDScriptFunctionState:
	# stop on first error if fail fast enabled
	if _fail_fast and _total_test_failed > 0:
		test_suite.free()
		return null
	
	add_child(test_suite)
	var fs = before(test_suite, test_suite.get_child_count())
	if GdUnitTools.is_yielded(fs):
		yield(fs, "completed")
		
	if not test_suite.is_skipped():
		for test_case_index in test_suite.get_child_count():
			var test_case = test_suite.get_child(test_case_index)
			# stop on first error if fail fast enabled
			if _fail_fast and _total_test_failed > 0:
				break
			test_suite.set_active_test_case(test_case.get_name())
			fs = execute_test_case(test_suite, test_case)
			# is yielded than wait for completed
			if GdUnitTools.is_yielded(fs):
				yield(fs, "completed")
				if test_case.is_interupted():
					# it needs to go this hard way to kill the outstanding yields of a test case when the test timed out
					# we delete the current test suite where is execute the current test case to kill the function state
					# and replace it by a clone without function state
					test_suite = clone_test_suite(test_suite)
	
	fs = after(test_suite)
	if GdUnitTools.is_yielded(fs):
		yield(fs, "completed")
	remove_child(test_suite)
	test_suite.free()
	return null

# clones a test suite and moves the test cases to new instance
func clone_test_suite(test_suite :GdUnitTestSuite) -> GdUnitTestSuite:
	var _test_suite = test_suite.duplicate()
	# copy all property values
	for property in test_suite.get_property_list():
		var property_name = property["name"]
		_test_suite.set(property_name, test_suite.get(property_name))
	
	# remove incomplete duplicated childs
	for child in _test_suite.get_children():
		_test_suite.remove_child(child)
		child.free()
	assert(_test_suite.get_child_count() == 0)
	# now move original test cases to duplicated test suite
	for child in test_suite.get_children():
		child.get_parent().remove_child(child)
		_test_suite.add_child(child)
	# finally free current test suite instance
	remove_child(test_suite)
	test_suite.free()
	add_child(_test_suite)
	return _test_suite

static func create_fuzzer(test_suite :GdUnitTestSuite, test_case :_TestCase) -> Fuzzer:
	if not test_case.has_fuzzer():
		return null
	var fuzzer := FuzzerTool.create_fuzzer(test_suite.get_script(), test_case.fuzzer_func())
	fuzzer._iteration_index = 0
	fuzzer._iteration_limit = test_case.iterations()
	return fuzzer

func _set_memory_pool(test_suite :GdUnitTestSuite, pool :int):
	test_suite.set_meta("MEMORY_POOL", pool)

# --- test report events
func _event_test_report(report :GdUnitReport):
	_reports.append(report)

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

func before(test_suite :GdUnitTestSuite, total_count :int) -> void:
	emit_signal("send_event", GdUnitEvent.new()\
		.before(test_suite.get_script().resource_path, test_suite.get_name(), total_count))
	_testsuite_timer = LocalTime.now()
	_total_test_orphan_nodes = 0
	_total_test_failed = 0
	_total_test_warnings = 0
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTSUITE)
	_mem_monitor_testsuite.start()
	test_suite.before()
	GdUnitTools.run_auto_close()

func after(test_suite :GdUnitTestSuite) -> void:
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTSUITE)
	test_suite.after()
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
	}
	emit_signal("send_event", GdUnitEvent.new().after(test_suite.get_script().resource_path, test_suite.get_name(), statistics, _reports.duplicate()))
	_reports.clear()

func before_test(test_suite :GdUnitTestSuite, test_case :_TestCase):
	_testcase_timer = LocalTime.now()
	_reports.clear()
	emit_signal("send_event", GdUnitEvent.new()\
		.beforeTest(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name()))
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTCASE)
	_mem_monitor_testcase.start()
	test_suite.before_test()
	GdUnitTools.run_auto_close()

func after_test(test_suite :GdUnitTestSuite, test_case :_TestCase):
	_set_memory_pool(test_suite, GdUnitTools.MEMORY_POOL_TESTCASE)
	test_suite.after_test()
	GdUnitTools.run_auto_free(GdUnitTools.MEMORY_POOL_TESTCASE)
	_mem_monitor_testcase.stop()
	_mem_monitor_testcase.subtract(_mem_monitor_testrun.orphan_nodes())

	var test_warnings := false
	var test_failed := not _reports.empty()
	var test_errors := false
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
		GdUnitEvent.FAILED: test_failed
	}
	
	emit_signal("send_event", GdUnitEvent.new()\
		.afterTest(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name(), statistics, _reports.duplicate()))
	_reports.clear()

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
	var test_errors := false
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
		GdUnitEvent.FAILED: test_failed
	}
	emit_signal("send_event", GdUnitEvent.new()\
		.testrun_after(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name(), statistics, _reports.duplicate()))
	_reports.clear()

func execute_test_case(test_suite :GdUnitTestSuite, test_case :_TestCase) -> GDScriptFunctionState:
	before_test(test_suite, test_case)
	var fuzzer := create_fuzzer(test_suite, test_case)
	
	_before_test_run(test_suite, test_case)
	if not fuzzer:
		_test_run_state = test_suite.call(test_case.get_name())
		# is yielded than wait for completed
		if _test_run_state is GDScriptFunctionState:
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
			_test_run_state = test_suite.call(test_case.get_name(), fuzzer)
			# is yielded than wait for completed
			if _test_run_state is GDScriptFunctionState:
				yield(_test_run_state, "completed")
	
	_after_test_run(test_suite, test_case)
	after_test(test_suite, test_case)
	return null

func execute(test_suite :GdUnitTestSuite) -> GDScriptFunctionState:
	# stop on first error if fail fast enabled
	if _fail_fast and _total_test_failed > 0:
		test_suite.free()
		return null
	
	add_child(test_suite)
	before(test_suite, test_suite.get_child_count())
	
	for test_case in test_suite.get_children():
		# stop on first error if fail fast enabled
		if _fail_fast and _total_test_failed > 0:
			break
		var fs = execute_test_case(test_suite, test_case)
		# is yielded than wait for completed
		if fs is GDScriptFunctionState:
			yield(fs, "completed")
	
	after(test_suite)
	remove_child(test_suite)
	test_suite.free()
	return null


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
	# break current running test on first error report
	if _test_run_state and _test_run_state.is_valid():
		_test_run_state.emit_signal("completed")

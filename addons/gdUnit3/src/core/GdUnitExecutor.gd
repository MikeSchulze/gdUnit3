class_name GdUnitExecutor
extends Node

signal send_event(event)
signal send_event_debug(event)

const INIT = 0
const STAGE_TEST_SUITE_BEFORE = GdUnitReportCollector.STAGE_TEST_SUITE_BEFORE
const STAGE_TEST_SUITE_AFTER = GdUnitReportCollector.STAGE_TEST_SUITE_AFTER
const STAGE_TEST_CASE_BEFORE = GdUnitReportCollector.STAGE_TEST_CASE_BEFORE
const STAGE_TEST_CASE_EXECUTE = GdUnitReportCollector.STAGE_TEST_CASE_EXECUTE
const STAGE_TEST_CASE_AFTER = GdUnitReportCollector.STAGE_TEST_CASE_AFTER

var _testsuite_timer :LocalTime
var _testcase_timer :LocalTime
var _testrun_timer :LocalTime

var _memory_pool :GdUnitMemoryPool
var _report_errors_enabled :bool
var _report_collector : = GdUnitReportCollector.new()

var _total_test_execution_orphans :int
var _total_test_warnings :int
var _total_test_failed :int
var _total_test_errors :int

var _test_run_state :GDScriptFunctionState
var _fail_fast := false

var _x = GdUnitArgumentMatchers.new()
var _debug_mode :bool

func _init(debug_mode := false):
	_debug_mode = debug_mode

func _ready():
	_report_errors_enabled = GdUnitSettings.is_report_push_errors()
	_memory_pool = GdUnitMemoryPool.new()
	add_child(_memory_pool)

func fail_fast(enabled :bool) -> void:
	_fail_fast = enabled

func set_stage(stage :int) -> void:
	_report_collector.set_stage(stage)

func fire_event(event :GdUnitEvent) -> void:
	if _debug_mode:
		emit_signal("send_event_debug", event)
	else:
		emit_signal("send_event", event)

func suite_before(test_suite :GdUnitTestSuite, total_count :int) -> GDScriptFunctionState:
	set_stage(STAGE_TEST_SUITE_BEFORE)
	fire_event(GdUnitEvent.new()\
		.suite_before(test_suite.get_script().resource_path, test_suite.get_name(), total_count))
	_testsuite_timer = LocalTime.now()
	_total_test_errors = 0
	_total_test_failed = 0
	_total_test_warnings = 0
	if not test_suite.is_skipped():
		_memory_pool.set_pool(test_suite, GdUnitMemoryPool.SUITE_SETUP, true)
		var fstate = test_suite.before()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
		_memory_pool.monitor_stop()
	GdUnitTools.run_auto_close()
	return null

func suite_after(test_suite :GdUnitTestSuite) -> GDScriptFunctionState:
	set_stage(STAGE_TEST_SUITE_AFTER)
	GdUnitTools.clear_tmp()
	
	var is_warning := _total_test_warnings != 0
	var is_skipped := test_suite.is_skipped()
	var skip_count := test_suite.get_child_count()
	var orphan_nodes := 0
	var reports := _report_collector.get_reports(STAGE_TEST_SUITE_BEFORE)
	
	if not is_skipped:
		_memory_pool.set_pool(test_suite, GdUnitMemoryPool.SUITE_SETUP)
		skip_count = 0
		var fstate = test_suite.after()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
		GdUnitTools.append_array(reports, _report_collector.get_reports(STAGE_TEST_SUITE_AFTER))
		GdUnitTools.run_auto_close()
		_memory_pool.free_pool()
		_memory_pool.monitor_stop()
		orphan_nodes = _memory_pool.orphan_nodes()
		if orphan_nodes > 0:
			reports.push_front(GdUnitReport.new() \
				.create(GdUnitReport.WARN, 1, GdAssertMessages.orphan_detected_on_suite_setup(orphan_nodes)))
	
	var is_error := _total_test_errors != 0 or _report_collector.has_errors(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER)
	var is_failed := _total_test_failed != 0 or _report_collector.has_failures(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER)
	# create report
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: orphan_nodes,
		GdUnitEvent.ELAPSED_TIME: _testsuite_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: is_warning,
		GdUnitEvent.ERRORS: is_error,
		GdUnitEvent.ERROR_COUNT: _report_collector.count_errors(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER),
		GdUnitEvent.FAILED: is_failed,
		GdUnitEvent.FAILED_COUNT: _report_collector.count_failures(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER),
		GdUnitEvent.SKIPPED_COUNT: skip_count,
		GdUnitEvent.SKIPPED: is_skipped
	}
	fire_event(GdUnitEvent.new().suite_after(test_suite.get_script().resource_path, test_suite.get_name(), statistics, reports))
	_report_collector.clear_reports(STAGE_TEST_SUITE_BEFORE|STAGE_TEST_SUITE_AFTER)
	return null

func test_before(test_suite :GdUnitTestSuite, test_case :_TestCase) -> GDScriptFunctionState:
	set_stage(STAGE_TEST_CASE_BEFORE)
	_memory_pool.set_pool(test_suite, GdUnitMemoryPool.TEST_SETUP, true)
	
	_testcase_timer = LocalTime.now()
	_total_test_execution_orphans = 0
	fire_event(GdUnitEvent.new()\
		.test_before(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name()))
	
	test_suite.set_meta(GdUnitAssertImpl.GD_TEST_FAILURE, false)
	if not test_case.is_skipped():
		var fstate = test_suite.before_test()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
	
	_memory_pool.monitor_stop()
	GdUnitTools.run_auto_close()
	return null

func test_after(test_suite :GdUnitTestSuite, test_case :_TestCase) -> GDScriptFunctionState:
	set_stage(STAGE_TEST_CASE_AFTER)
	_memory_pool.set_pool(test_suite, GdUnitMemoryPool.TEST_SETUP)
	
	if not test_case.is_skipped():
		var fstate = test_suite.after_test()
		if GdUnitTools.is_yielded(fstate):
			yield(fstate, "completed")
		_memory_pool.free_pool()
		_memory_pool.monitor_stop()
		var test_setup_orphan_nodes = _memory_pool.orphan_nodes()
		if test_setup_orphan_nodes > 0:
			_total_test_warnings += 1
			_total_test_execution_orphans += test_setup_orphan_nodes
			_report_collector.push_front(STAGE_TEST_CASE_AFTER, GdUnitReport.new() \
				.create(GdUnitReport.WARN, test_case.line_number(), GdAssertMessages.orphan_detected_on_test_setup(test_setup_orphan_nodes)))
	
	var reports := _report_collector.get_reports(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	var is_error := test_case.is_interupted() and not test_case.is_expect_interupted()
	var error_count := _report_collector.count_errors(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	var failure_count := _report_collector.count_failures(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	var is_warning := _report_collector.has_warnings(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	
	_total_test_errors += error_count
	_total_test_failed += failure_count
	var statistics = {
		GdUnitEvent.ORPHAN_NODES: _total_test_execution_orphans,
		GdUnitEvent.ELAPSED_TIME: _testcase_timer.elapsed_since_ms(),
		GdUnitEvent.WARNINGS: is_warning,
		GdUnitEvent.ERRORS: is_error,
		GdUnitEvent.ERROR_COUNT: error_count,
		GdUnitEvent.FAILED: failure_count > 0,
		GdUnitEvent.FAILED_COUNT: failure_count,
		GdUnitEvent.SKIPPED: test_case.is_skipped(),
		GdUnitEvent.SKIPPED_COUNT: int(test_case.is_skipped()),
	}
	
	fire_event(GdUnitEvent.new()\
		.test_after(test_suite.get_script().resource_path, test_suite.get_name(), test_case.get_name(), statistics, reports.duplicate()))
	_report_collector.clear_reports(STAGE_TEST_CASE_BEFORE|STAGE_TEST_CASE_EXECUTE|STAGE_TEST_CASE_AFTER)
	return null

func execute_test_case(test_suite :GdUnitTestSuite, test_case :_TestCase) -> GDScriptFunctionState:
	_test_run_state = test_before(test_suite, test_case)
	if GdUnitTools.is_yielded(_test_run_state):
		yield(_test_run_state, "completed")
		_test_run_state = null
	
	_testrun_timer = LocalTime.now()
	set_stage(STAGE_TEST_CASE_EXECUTE)
	_memory_pool.set_pool(test_suite, GdUnitMemoryPool.TEST_EXECUTE, true)
	test_case.generate_seed()
	
	if not test_case.is_skipped():
		if not test_case.has_fuzzer():
			_test_run_state = test_case.execute()
			# is yielded than wait for completed
			if GdUnitTools.is_yielded(_test_run_state):
				yield(_test_run_state, "completed")
		else:
			var fuzzers := create_fuzzers(test_suite, test_case)
			for iteration in test_case.iterations():
				# interrupt at first failure
				var reports := _report_collector.get_reports(STAGE_TEST_CASE_EXECUTE)
				if not reports.empty():
					var report :GdUnitReport = _report_collector.pop_front(STAGE_TEST_CASE_EXECUTE)
					_report_collector.add_report(STAGE_TEST_CASE_EXECUTE, GdUnitReport.new() \
							.create(GdUnitReport.FAILURE, report.line_number(), GdAssertMessages.fuzzer_interuped(iteration-1, report.message())))
					break
				_test_run_state = test_case.execute(fuzzers, iteration)
				# is yielded than wait for completed
				if GdUnitTools.is_yielded(_test_run_state):
					yield(_test_run_state, "completed")
				if test_case.is_interupted():
					break
	
	_memory_pool.free_pool()
	# give objects time to finallize
	yield(get_tree(), "idle_frame")
	_memory_pool.monitor_stop()
	var execution_orphan_nodes = _memory_pool.orphan_nodes()
	if execution_orphan_nodes > 0:
		_total_test_execution_orphans += execution_orphan_nodes
		_total_test_warnings += 1
		_report_collector.push_front(STAGE_TEST_CASE_EXECUTE, GdUnitReport.new() \
			.create(GdUnitReport.WARN, test_case.line_number(), GdAssertMessages.orphan_detected_on_test(execution_orphan_nodes)))
	
	if test_case.is_interupted() and not test_case.is_expect_interupted():
		_report_collector.add_report(STAGE_TEST_CASE_EXECUTE, GdUnitReport.new() \
				.create(GdUnitReport.INTERUPTED, test_case.line_number(), "Test timed out suite_after %s" % LocalTime.elapsed(test_case.timeout())))
	
	_test_run_state = test_after(test_suite, test_case)
	if GdUnitTools.is_yielded(_test_run_state):
		yield(_test_run_state, "completed")
		_test_run_state = null
	return _test_run_state

func execute(test_suite :GdUnitTestSuite) -> GDScriptFunctionState:
	# stop on first error if fail fast enabled
	if _fail_fast and _total_test_failed > 0:
		test_suite.free()
		return null
	
	_report_collector.register_report_provider(test_suite)
	add_child(test_suite)
	var fs = suite_before(test_suite, test_suite.get_child_count())
	if GdUnitTools.is_yielded(fs):
		yield(fs, "completed")
	
	if not test_suite.is_skipped():
		for test_case_index in test_suite.get_child_count():
			var test_case = test_suite.get_child(test_case_index)
			# only iterate over test case, we need to filter because of possible adding other child types on before() or before_test()
			if not test_case is _TestCase:
				continue
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
	
	fs = suite_after(test_suite)
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

static func create_fuzzers(test_suite :GdUnitTestSuite, test_case :_TestCase) -> Array:
	if not test_case.has_fuzzer():
		return Array()
	var fuzzers := Array()
	for fuzzer_def in test_case.fuzzers():
		var fuzzer := FuzzerTool.create_fuzzer(test_suite.get_script(), fuzzer_def)
		fuzzer._iteration_index = 0
		fuzzer._iteration_limit = test_case.iterations()
		fuzzers.append(fuzzer)
	return fuzzers

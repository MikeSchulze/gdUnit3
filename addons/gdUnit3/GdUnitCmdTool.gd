#!/usr/bin/env -S godot -s
extends SceneTree

enum {
	INIT,
	RUN,
	STOP,
	EXIT
}
var _state = INIT


var _config :Dictionary
var _test_suites_to_process :Array

var _executor
var _signal_handler


func _initialize():
	_state = INIT
	_signal_handler = GdUnitSingleton.get_or_create_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
	_config = GdUnitRunnerConfig.load_config()
	_test_suites_to_process = load_test_suits()


func _idle(delta):
	match _state:
		INIT:
			gdUnitInit()
			_state = RUN
		RUN:
			root.set_process(false)
			# all test suites executed
			if _test_suites_to_process.empty():
				_state = STOP
			else:
				pass
				# process next test suite
				var test_suite := _test_suites_to_process.pop_front() as GdUnitTestSuite
				var fs = _executor.execute(test_suite)
				if fs is GDScriptFunctionState:
					yield(fs, "completed")
				
			root.set_process(true)
		STOP:
			_state = EXIT
			# give the engine small amount time to finish the rpc
			yield(create_timer(0.1), "timeout")
			_on_executor_event(GdUnitStop.new())
			
			quit(0)

func _finalize():
	root.remove_child(_executor)
	#_signal_handler.free()
	_executor.free()
	#_gdUnitRunner.send_message("Close GdUnitClient")
	pass


func load_test_suits() -> Array:
	var test_suite_resources :Array = _config.get(GdUnitRunnerConfig.SELECTED_TEST_SUITE_RESOURCES, ["res://addons/gdUnit3/test/"])
	var selected_test_case :String = _config.get(GdUnitRunnerConfig.SELECTED_TEST_CASE, "")

	# scan for the requested test suites
	var test_suites := Array()
	var _scanner := _TestSuiteScanner.new()
	for resource_path in test_suite_resources:
		test_suites += _scanner.scan(resource_path)
	_scanner.free()
	
	# only a single test case run is requested, filter out all others
	if not selected_test_case.empty():
		_filter_test_case(test_suites, selected_test_case)

	return test_suites

func _filter_test_case(test_suites :Array, test_case_name :String) -> void:
	for test_suite in test_suites:
		for test_case in test_suite.get_children():
			if test_case.get_name() != test_case_name:
				test_suite.remove_child(test_case)
				test_case.free()

func _collect_test_case_count(testSuites :Array) -> int:
	var total :int = 0
	for test_suite in testSuites:
		total += (test_suite as Node).get_child_count()
	return total


func gdUnitInit() -> void:
	_executor = GdUnitExecutor.new()
	_executor.connect("send_event", self, "_on_executor_event")
	root.add_child(_executor)
	
	send_message("Scaned %d test suites" % _test_suites_to_process.size())
	var total_test_count = _collect_test_case_count(_test_suites_to_process)
	_on_executor_event(GdUnitInit.new(_test_suites_to_process.size(), total_test_count))

var _report_summary :GdUnitReportSummary


func _on_executor_event(event :GdUnitEvent):
	#prints("_on_Executor_send_event", event)
	match event.type():
		GdUnitEvent.INIT:
			var summary := event as GdUnitInit
			_report_summary = GdUnitReportSummary.new(
				summary.total_test_suites(), 
				summary.total_tests())
		
		
		GdUnitEvent.STOP:
			var report_dir := GdUnitTools.current_dir() + "report"
			_report_summary.stop_timer()
			_report_summary.write_html_report(report_dir)
		
		
		GdUnitEvent.TESTSUITE_BEFORE:
			var report = GdUnitTestSuiteReport.new(
				event.resource_path(), 
				event.suite_name(), 
				event.total_count())
			_report_summary.add_report(report)
			
			
		GdUnitEvent.TESTSUITE_AFTER:
			
			_report_summary.set_summary(
				event.suite_name(), 
				0, #failures 
				0, # errors
				event.orphan_nodes())
			
			
		GdUnitEvent.TESTCASE_BEFORE:
			
			#prints("\t%s:%s" % [event._suite_name, event._test_name])
			pass
			
			
		GdUnitEvent.TESTCASE_AFTER:
			
			if event.is_failed():
				prints(event.suite_name(), event.test_name(), event.reports())
			
			pass
			
			
		GdUnitEvent.TESTRUN_BEFORE:
			pass
			
			
		GdUnitEvent.TESTRUN_AFTER:
			pass





func send_message(message :String):
	prints("send_message", message)
	pass

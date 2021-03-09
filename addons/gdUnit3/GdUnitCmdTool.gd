#!/usr/bin/env -S godot -s
extends SceneTree


class CLIRunner extends Node:
	enum {
		INIT,
		RUN,
		STOP,
		EXIT
	}

	var _state = INIT
	var _signal_handler
	var _test_suites_to_process :Array
	var _executor
	
	func _init():
		_state = INIT
		_signal_handler = GdUnitSingleton.get_or_create_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
		
		_executor = GdUnitExecutor.new()
		# needs to disable the default yielding, it is only need when run in client/server context 
		_executor.disable_default_yield()
		_executor.connect("send_event", self, "_on_executor_event")
		add_child(_executor)
	
	func _process(delta):
		match _state:
			INIT:
				gdUnitInit()
				_state = RUN
			RUN:
				set_process(false)
				# all test suites executed
				if _test_suites_to_process.empty():
					_state = STOP
				else:
					# process next test suite
					var test_suite := _test_suites_to_process.pop_front() as GdUnitTestSuite
					var fs = _executor.execute(test_suite)
					if fs is GDScriptFunctionState:
						yield(fs, "completed")
				set_process(true)
			STOP:
				_state = EXIT
				_on_executor_event(GdUnitStop.new())
				get_tree().quit(0)

	func gdUnitInit() -> void:
		_test_suites_to_process = load_test_suits()
		var total_test_count = _collect_test_case_count(_test_suites_to_process)
		_on_executor_event(GdUnitInit.new(_test_suites_to_process.size(), total_test_count))
		
	func load_test_suits() -> Array:
		var config = GdUnitRunnerConfig.load_config()
		var test_suite_resources :Array = config.get(GdUnitRunnerConfig.SELECTED_TEST_SUITE_RESOURCES, ["res://addons/gdUnit3/test/"])
		var selected_test_case :String = config.get(GdUnitRunnerConfig.SELECTED_TEST_CASE, "")

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

	var _report :GdUnitHtmlReport
	
	func _on_executor_event(event :GdUnitEvent):
		match event.type():
			GdUnitEvent.INIT:
				var summary := event as GdUnitInit
				_report = GdUnitHtmlReport.new()
			
			
			GdUnitEvent.STOP:
				var report_dir := GdUnitTools.current_dir() + "report"
				var report_path := _report.write(report_dir)
				prints("Open Report at:", "file://%s" % report_path)
			
			
			GdUnitEvent.TESTSUITE_BEFORE:
				prints("Run Test Suite", event.resource_path())
				var suite_report := GdUnitTestSuiteReport.new(
					event.resource_path(),
					event.suite_name())
				_report.add_testsuite_report(suite_report)
				
				
				
			GdUnitEvent.TESTSUITE_AFTER:
				if event.is_failed():
					prints("failed", LocalTime.elapsed(event.elapsed_time()))
				else:
					prints("success", LocalTime.elapsed(event.elapsed_time()))
				_report.set_testsuite_duration(event.suite_name(), event.elapsed_time())
				
			GdUnitEvent.TESTCASE_BEFORE:
				prints("	Run Test: %s > %s STARTED" % [event.resource_path(), event.test_name()])
				
				
			GdUnitEvent.TESTCASE_AFTER:
				if event.is_failed():
					prints("	Run Test: %s > %s FAILED" % [event.resource_path(), event.test_name()], LocalTime.elapsed(event.elapsed_time()))
				else:
					prints("	Run Test: %s > %s PASSED" % [event.resource_path(), event.test_name()], LocalTime.elapsed(event.elapsed_time()))
				
			GdUnitEvent.TESTRUN_BEFORE:
				pass
				
				
			GdUnitEvent.TESTRUN_AFTER:
				var test_report := GdUnitTestCaseReport.new(
					event.test_name(),
					event.is_failed(),
					event.orphan_nodes(),
					event.reports(),
					event.elapsed_time())
				_report.add_testcase_report(event.suite_name(), test_report)
	
	
	func _notification(what):
		#prints("_notification", self, GdObjects.notification_as_string(what))
		pass

func _initialize():
	root.add_child(CLIRunner.new())


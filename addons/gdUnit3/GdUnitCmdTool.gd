#!/usr/bin/env -S godot -s
extends SceneTree


const GD_CMD_SERVER_PORT :int = 31088

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
				yield(_executor.execute(test_suite), "completed")
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
var _testsuite_timer :LocalTime

func _on_executor_event(event :GdUnitEvent):
	#prints("_on_Executor_send_event", event)
	match event.type():
		GdUnitEvent.INIT:
			_testsuite_timer = LocalTime.now()
			var summary := event as GdUnitInit
			_report_summary = GdUnitReportSummary.new(summary.total_test_suites(), summary.total_tests())
		
		
		GdUnitEvent.STOP:
			_report_summary._duration = _testsuite_timer.elapsed_since()
			
			write_report(_report_summary)
		
		
		GdUnitEvent.TESTSUITE_BEFORE:
			
			pass
			
			
		GdUnitEvent.TESTSUITE_AFTER:
			#prints("%s" % "FINISHED | PASSED:" + str(event._success_count) + "| FAILED:" + str(event._failed_count))
			pass
			
			
		GdUnitEvent.TESTCASE_BEFORE:
			
			#prints("\t%s:%s" % [event._suite_name, event._test_name])
			pass
			
			
		GdUnitEvent.TESTCASE_AFTER:

			
			
			
			pass
			
			
		GdUnitEvent.TESTRUN_BEFORE:
			pass
			
			
		GdUnitEvent.TESTRUN_AFTER:
			pass

	

func write_report(report_summary :GdUnitReportSummary):
	var report_dir := GdUnitTools.create_temp_dir("report")
	GdUnitTools.copy_file("res://addons/gdUnit3/src/report/template/index.html", report_dir)
	GdUnitTools.copy_directory("res://addons/gdUnit3/src/report/template/css/", report_dir)
	
	var file = File.new()
	file.open("%s/index.html" % report_dir, File.READ)
	var content = file.get_as_text()
	content = content.replace("${testsuites}", report_summary._testsiutes)
	content = content.replace("${tests}", report_summary._tests)
	content = content.replace("${failures}", report_summary._errors)
	content = content.replace("${orphans}", report_summary._orphans)
	content = content.replace("${duration}", report_summary._duration)
	file.close()

	
	file.open("%s/index.html" % report_dir, File.WRITE)
	file.store_string(content)
	file.close()

	
	var report := OS.get_user_data_dir() + "/tmp/report/index.html"
	prints("Open Report at:", "'start "+report+"'")


func send_message(message :String):
	prints("send_message", message)
	pass

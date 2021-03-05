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
	var _executor :GdUnitExecutor
	var _report :GdUnitHtmlReport
	var _runner_config := GdUnitRunnerConfig.new()
	
	func _init():
		_state = INIT
		_signal_handler = GdUnitSingleton.get_or_create_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
		
		_executor = GdUnitExecutor.new()
		# needs to disable the default yielding, it is only need when run in client/server context 
		_executor.disable_default_yield()
		# stop on first test failure to fail fast
		_executor.fail_fast(true)
		var err := _executor.connect("send_event", self, "_on_executor_event")
		if err != OK:
			push_error("Error on startup, can't connect executor for 'send_event'")
			get_tree().quit(1)
		add_child(_executor)
	
	func _process(_delta):
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
				get_tree().quit(report_exit_code(_report))
	
	func print_version() -> void:
		prints(Engine.get_version_info())
		prints("GdUnit3 v0.9.0 - beta")
		get_tree().quit(0)
	
	func disable_fail_fast() -> void:
		_executor.fail_fast(false)
	
	func run_self_test() -> void:
		disable_fail_fast()
		_runner_config.self_test()
	
	func gdUnitInit() -> void:
		prints("-- GdUnit3 Comandline Tool -----")
		var options: = CmdOptions.new([
			CmdOption.new("-add, --add-suite, --add-directory", "--add <suite-name|directory>", "Adds the given test suite or directory to the execution pipeline.", TYPE_STRING),
			CmdOption.new("-ignore, --ignore-suite", "-ignore <suite-name|suite-name:test-name>", "Adds the given test suite or test case to the ignore list.", TYPE_STRING),
			CmdOption.new("-c, --continue", "", "By default GdUnit will abort on first test failure to be fail fast, instead of stop after first failure you can use this option to run the complete test set."),
			CmdOption.new("-wr, --write-report", "-wr [report directory]", "Writes an HTML report to the specified directory. If no directory is specified, the project root directory is used as the default location.", TYPE_STRING, true)
		], [
			# advanced options
			CmdOption.new("--list-suites", "--list-suites [directory]", "Lists all test suites located in the given directory.", TYPE_STRING),
			CmdOption.new("--describe-suite", "--describe-suite <suite name>", "Shows the description of selected test suite.", TYPE_STRING),
			CmdOption.new("--info", "", "Shows the GdUnit version info"),
			CmdOption.new("--selftest", "", "Runs the GdUnit self test"),
		])
		var cmd_parser := CmdArgumentParser.new(options, "GdUnitCmdTool.gd")
		if cmd_parser.parse(OS.get_cmdline_args()) != 0:
			options.print_options()
			GdUnitTools.prints_error("Abnormal exit with -1")
			get_tree().quit(-1)
			return
		
		# build runner config by given commands
		var result := CmdCommandHandler.new(options)\
			.register_cb("-add", funcref(_runner_config, "add_test_suite"))\
			.register_cbv("-add", funcref(_runner_config, "add_test_suites"))\
			.register_cb("--selftest", funcref(self, "run_self_test"))\
			.register_cb("-c", funcref(self, "disable_fail_fast"))\
			.register_cb("--info", funcref(self, "print_version"))\
			.execute(cmd_parser.commands())
		if result.is_error():
			GdUnitTools.prints_error(result.error_message())
			_state = STOP
			get_tree().quit(0)
			
		_test_suites_to_process = load_testsuites(_runner_config)
		var total_test_count = _collect_test_case_count(_test_suites_to_process)
		prints("total_test_count", total_test_count)
		_on_executor_event(GdUnitInit.new(_test_suites_to_process.size(), total_test_count))
	
	func load_testsuites(config :GdUnitRunnerConfig) -> Array:
		var test_suites_to_process = Array()
		var to_execute := config.to_execute()
		
		# scan for the requested test suites
		var _scanner := _TestSuiteScanner.new()
		for resource_path in to_execute.keys():
			var selected_tests :Array = to_execute.get(resource_path)
			var scaned_suites := _scanner.scan(resource_path)
			_filter_test_case(scaned_suites, selected_tests)
			test_suites_to_process += scaned_suites
		_scanner.free()
		return test_suites_to_process
	
	func _filter_test_case(test_suites :Array, test_case_names :Array) -> void:
		if test_case_names.empty():
			return
		for test_suite in test_suites:
			for test_case in test_suite.get_children():
				if not test_case_names.has(test_case.get_name()):
					prints("filter out", test_case.get_name())
					test_suite.remove_child(test_case)
					test_case.free()
	
	func _collect_test_case_count(testSuites :Array) -> int:
		var total :int = 0
		for test_suite in testSuites:
			total += (test_suite as Node).get_child_count()
		return total
	
	func _on_executor_event(event :GdUnitEvent):
		print_status(event)
		
		match event.type():
			GdUnitEvent.INIT:
				_report = GdUnitHtmlReport.new()
			
			
			GdUnitEvent.STOP:
				var report_dir := GdUnitTools.current_dir() + "report"
				var report_path := _report.write(report_dir)
				prints("Open Report at:", "file://%s" % report_path)
			
			
			GdUnitEvent.TESTSUITE_BEFORE:
				var suite_report := GdUnitTestSuiteReport.new(
					event.resource_path(),
					event.suite_name())
				_report.add_testsuite_report(suite_report)
				
				
			GdUnitEvent.TESTSUITE_AFTER:
				_report.set_testsuite_duration(event.suite_name(), event.elapsed_time())
				
				
			GdUnitEvent.TESTCASE_AFTER:
				pass
				
				
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
	
	
	func report_exit_code(report :GdUnitHtmlReport) -> int:
		if report.failure_count() > 0:
			return 1
		if report.orphan_count() > 0:
			return 2
		return 0
	
	func print_status(event :GdUnitEvent) -> void:
		match event.type():
			GdUnitEvent.TESTSUITE_BEFORE:
				prints("Run Test Suite", event.resource_path())
				
			GdUnitEvent.TESTCASE_BEFORE:
				prints("	Run Test: %s > %s STARTED" % [event.resource_path(), event.test_name()])
				
			GdUnitEvent.TESTRUN_AFTER:
				if event.is_failed():
					prints("	Run Test: %s > %s %s" % [event.resource_path(), event.test_name(), GdUnitTools.printraw_error("FAILED", false)], LocalTime.elapsed(event.elapsed_time()))
				else:
					prints("	Run Test: %s > %s %s" % [event.resource_path(), event.test_name(), GdUnitTools.printraw_info("PASSED", false)], LocalTime.elapsed(event.elapsed_time()))
			
			GdUnitEvent.TESTSUITE_AFTER:
				if event.is_failed():
					printraw( GdUnitTools.printraw_error("FAILED ", false), LocalTime.elapsed(event.elapsed_time()))
				else:
					printraw(GdUnitTools.printraw_info("PASSED ", false), LocalTime.elapsed(event.elapsed_time()))
				prints( "	| %d total | %d failed | %d orphans |\n" % [_report.test_count(), _report.failure_count(), _report.orphan_count()])
	
	
	#func _notification(what):
		#prints("_notification", self, GdObjects.notification_as_string(what))
	#	pass

func _initialize():
	root.add_child(CLIRunner.new())

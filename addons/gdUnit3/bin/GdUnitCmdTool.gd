#!/usr/bin/env -S godot -s
extends SceneTree

#warning-ignore-all:return_value_discarded
class CLIRunner extends Node:
	
	enum {
		INIT,
		RUN,
		STOP,
		EXIT
	}
	const DEFAULT_REPORT_COUNT = 20
	const RETURN_SUCCESS  =   0
	const RETURN_ERROR    = 100
	const RETURN_WARNING  = 101
	
	var _state = INIT
	var _signal_handler
	var _test_suites_to_process :Array
	var _executor :GdUnitExecutor
	var _report :GdUnitHtmlReport
	var _report_dir: String
	var _report_max: int = DEFAULT_REPORT_COUNT
	var _runner_config := GdUnitRunnerConfig.new()
	var _console := CmdConsole.new()
	
	var _cmd_options: = CmdOptions.new([
			CmdOption.new("-a, --add", "-a <directory|path of testsuite>", "Adds the given test suite or directory to the execution pipeline.", TYPE_STRING),
			CmdOption.new("-i, --ignore", "-i <testsuite_name|testsuite_name:test-name>", "Adds the given test suite or test case to the ignore list.", TYPE_STRING),
			CmdOption.new("-c, --continue", "", "By default GdUnit will abort on first test failure to be fail fast, instead of stop after first failure you can use this option to run the complete test set."),
			CmdOption.new("-conf, --config", "-conf [testconfiguration.cfg]", "Run all tests by given test configuration. Default is 'GdUnitRunner.cfg'", TYPE_STRING, true),
		], [
			# advanced options
			CmdOption.new("-rd, --report-directory", "-rd <directory>", "Specifies the output directory in which the reports are to be written. The default is res://reports/.", TYPE_STRING, true),
			CmdOption.new("-rc, --report-count", "-rc <count>", "Specifies how many reports are saved before they are deleted. The default is "+str(DEFAULT_REPORT_COUNT)+".", TYPE_INT, true),
			#CmdOption.new("--list-suites", "--list-suites [directory]", "Lists all test suites located in the given directory.", TYPE_STRING),
			#CmdOption.new("--describe-suite", "--describe-suite <suite name>", "Shows the description of selected test suite.", TYPE_STRING),
			CmdOption.new("--info", "", "Shows the GdUnit version info"),
			CmdOption.new("--selftest", "", "Runs the GdUnit self test"),
		])
	
	func _init():
		_state = INIT
		_signal_handler = GdUnitSingleton.get_or_create_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
		_report_dir = GdUnitTools.current_dir() + "reports"
		
		_executor = GdUnitExecutor.new()
		# stop on first test failure to fail fast
		_executor.fail_fast(true)
		var err := _executor.connect("send_event", self, "_on_executor_event")
		if err != OK:
			push_error("Error on startup, can't connect executor for 'send_event'")
			get_tree().quit(RETURN_ERROR)
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
	
	func set_report_dir(path :String) -> void:
		_report_dir = ProjectSettings.globalize_path(GdUnitTools.make_qualified_path(path))
		_console.prints_color("Set write reports to %s" % _report_dir, Color.deepskyblue)
		
	func set_report_count(count :String) -> void:
		var report_count := int(count)
		if report_count < 1:
			_console.prints_error("Invalid report history count '%s' set back to default %d" % [count, DEFAULT_REPORT_COUNT])
			_report_max = DEFAULT_REPORT_COUNT
		else:
			_console.prints_color("Set report history count to %s" % count, Color.deepskyblue)
			_report_max = int(count)
	
	func disable_fail_fast() -> void:
		_console.prints_color("Disabled fail fast!", Color.deepskyblue)
		_executor.fail_fast(false)
	
	func run_self_test() -> void:
		_console.prints_color("Run GdUnit3 self tests.", Color.deepskyblue)
		disable_fail_fast()
		_runner_config.self_test()
	
	func show_version() -> void:
		_console.prints_color("Godot %s" % Engine.get_version_info().get("string"), Color.darksalmon)
		var config = ConfigFile.new()
		config.load('addons/gdUnit3/plugin.cfg')
		_console.prints_color("GdUnit3 %s" % config.get_value('plugin', 'version'), Color.darksalmon)
		get_tree().quit(RETURN_SUCCESS)
	
	func show_options(show_advanced :bool = false) -> void:
		_console.prints_color(" Usage:", Color.darksalmon)
		_console.prints_color("	runtest -a <directory|path of testsiute>", Color.darksalmon)
		_console.prints_color("	runtest -a <directory> -i <path of testsuite|testsuite_name|testsuite_name:test_name>", Color.darksalmon).new_line()
		_console.prints_color("-- Options ---------------------------------------------------------------------------------------", Color.darksalmon).new_line()
		for option in _cmd_options.default_options():
			descripe_option(option)
		if show_advanced:
			_console.prints_color("-- Advanced options --------------------------------------------------------------------------", Color.darksalmon).new_line()
			for option in _cmd_options.advanced_options():
				descripe_option(option)
	
	func descripe_option(cmd_option :CmdOption) -> void:
		_console.print_color("  %-40s" % str(cmd_option.commands()), Color.cornflower)
		_console.prints_color(cmd_option.description(), Color.lightgreen)
		if not cmd_option.help().empty():
			_console.prints_color("%-4s %s" % ["", cmd_option.help()], Color.darkturquoise)
		_console.new_line()
		
	func load_test_config(path :String = "GdUnitRunner.cfg") -> void:
		_console.print_color("Loading test configuration %s\n" % path, Color.cornflower)
		_runner_config.load(path)
	
	func show_help() -> void:
		show_options()
		get_tree().quit(RETURN_SUCCESS)
	
	func show_advanced_help() -> void:
		show_options(true)
		get_tree().quit(RETURN_SUCCESS)
	
	func gdUnitInit() -> void:
		_console.prints_color("----------------------------------------------------------------------------------------------", Color.darksalmon)
		_console.prints_color(" GdUnit3 Comandline Tool", Color.darksalmon)
		_console.new_line()
		
		var cmd_parser := CmdArgumentParser.new(_cmd_options, "GdUnitCmdTool.gd")
		var result := cmd_parser.parse(OS.get_cmdline_args())
		if result.is_error():
			show_options()
			_console.prints_error(result.error_message())
			_console.prints_error("Abnormal exit with %d" % RETURN_ERROR)
			_state = STOP
			get_tree().quit(RETURN_ERROR)
			return
		
		if result.is_empty():
			show_help()
			return
		
		# build runner config by given commands
		result = CmdCommandHandler.new(_cmd_options)\
			.register_cb("-help", funcref(self, "show_help"))\
			.register_cb("--help-advanced", funcref(self, "show_advanced_help"))\
			.register_cb("-a", funcref(_runner_config, "add_test_suite"))\
			.register_cbv("-a", funcref(_runner_config, "add_test_suites"))\
			.register_cb("-i", funcref(_runner_config, "skip_test_suite"))\
			.register_cbv("-i", funcref(_runner_config, "skip_test_suites"))\
			.register_cb("-rd", funcref(self, "set_report_dir"))\
			.register_cb("-rc", funcref(self, "set_report_count"))\
			.register_cb("--selftest", funcref(self, "run_self_test"))\
			.register_cb("-c", funcref(self, "disable_fail_fast"))\
			.register_cb("-conf", funcref(self, "load_test_config"))\
			.register_cb("--info", funcref(self, "show_version"))\
			.execute(result.value())
		if result.is_error():
			_console.prints_error(result.error_message())
			_state = STOP
			get_tree().quit(RETURN_ERROR)
		
		_test_suites_to_process = load_testsuites(_runner_config)
		if _test_suites_to_process.empty():
			_console.prints_warning("No test suites found, abort test run!")
			_console.prints_color("Exit code: %d" % RETURN_SUCCESS,  Color.darksalmon)
			_state = STOP
			get_tree().quit(RETURN_SUCCESS)
		
		# wait comamnd handler is finish, e.g. exit program on show help
		yield(get_tree(), "idle_frame")
		var total_test_count = _collect_test_case_count(_test_suites_to_process)
		_on_executor_event(GdUnitInit.new(_test_suites_to_process.size(), total_test_count))
	
	func load_testsuites(config :GdUnitRunnerConfig) -> Array:
		var test_suites_to_process = Array()
		var to_execute := config.to_execute()
		
		# scan for the requested test suites
		var _scanner := _TestSuiteScanner.new()
		for resource_path in to_execute.keys():
			var selected_tests :Array = to_execute.get(resource_path)
			var scaned_suites = _scanner.scan(resource_path)
			skip_test_case(scaned_suites, selected_tests)
			test_suites_to_process += scaned_suites
		_scanner.free()
		
		skip_suites(test_suites_to_process, config)
		return test_suites_to_process
	
	func skip_test_case(test_suites :Array, test_case_names :Array) -> void:
		if test_case_names.empty():
			return
		for test_suite in test_suites:
			for test_case in test_suite.get_children():
				if not test_case_names.has(test_case.get_name()):
					test_suite.remove_child(test_case)
					test_case.free()
	
	func skip_suites(test_suites :Array, config :GdUnitRunnerConfig) -> void:
		var skipped := config.skipped()
		for test_suite in test_suites:
			skip_suite(test_suite, skipped)
	
	func skip_suite(test_suite :GdUnitTestSuite, skipped :Dictionary) -> void:
		var skipped_suites := skipped.keys()
		if skipped_suites.empty():
			return
		var suite_name := test_suite.get_name()
		var test_suite_path :String = test_suite.get_script().resource_path
		for suite_to_skip in skipped_suites:
			# if suite skipped by path or name
			if suite_to_skip == test_suite_path or (suite_to_skip.is_valid_filename() and suite_to_skip == suite_name):
				var skipped_tests :Array = skipped.get(suite_to_skip)
				# if no tests skipped test the complete suite is skipped
				if skipped_tests.empty():
					test_suite.skip(true)
				else:
					# skip tests
					for test_to_skip in skipped_tests:
						var test_case :_TestCase = test_suite.find_node(test_to_skip, true, false)
						if test_case:
							test_case.skip(true)
						else:
							_console.prints_error("Can't skip test '%s' on test suite '%s', no test with given name exists!" % [test_to_skip, suite_to_skip])
	
	func _collect_test_case_count(testSuites :Array) -> int:
		var total :int = 0
		for test_suite in testSuites:
			total += (test_suite as Node).get_child_count()
		return total
	
	func _on_executor_event(event :GdUnitEvent):
		match event.type():
			GdUnitEvent.INIT:
				_report = GdUnitHtmlReport.new(_report_dir)
			
			GdUnitEvent.STOP:
				var report_path := _report.write()
				_report.delete_history(_report_max)
				_console.prints_color("Total time %s" % LocalTime.elapsed(_report.duration()), Color.darksalmon)
				_console.prints_color("Open Report at: file://%s" % report_path, Color.cornflower)
			
			GdUnitEvent.TESTSUITE_BEFORE:
				_report.add_testsuite_report(GdUnitTestSuiteReport.new(event.resource_path(), event.suite_name()))
			
			GdUnitEvent.TESTSUITE_AFTER:
				_report.update_test_suite_report(event.suite_name(), event.skipped_count(), event.orphan_nodes(),  event.elapsed_time())
				
			GdUnitEvent.TESTCASE_BEFORE:
				_report.add_testcase_report(event.suite_name(), GdUnitTestCaseReport.new(event.test_name()))
			
			GdUnitEvent.TESTCASE_AFTER:
				var test_report := GdUnitTestCaseReport.new(
					event.test_name(),
					event.is_error(),
					event.is_failed(),
					event.orphan_nodes(),
					event.skipped_count(),
					event.reports(),
					event.elapsed_time())
				_report.update_testcase_report(event.suite_name(), test_report)
		print_status(event)
	
	func report_exit_code(report :GdUnitHtmlReport) -> int:
		if report.error_count() + report.failure_count() > 0:
			_console.prints_color("Exit code: %d" % RETURN_ERROR, Color.firebrick)
			return RETURN_ERROR
		if report.orphan_count() > 0:
			_console.prints_color("Exit code: %d" % RETURN_WARNING, Color.goldenrod)
			return RETURN_WARNING
		_console.prints_color("Exit code: %d" % RETURN_SUCCESS,  Color.darksalmon)
		return RETURN_SUCCESS
	
	func print_status(event :GdUnitEvent) -> void:
		match event.type():
			GdUnitEvent.TESTSUITE_BEFORE:
				_console.prints_color("Run Test Suite %s " % event.resource_path(), Color.antiquewhite)
			
			GdUnitEvent.TESTCASE_BEFORE:
				_console.print_color("	Run Test: %s > %s :" % [event.resource_path(), event.test_name()], Color.antiquewhite)\
					.prints_color("STARTED", Color.forestgreen)
			
			GdUnitEvent.TESTCASE_AFTER:
				_console.print_color("	Run Test: %s > %s :" % [event.resource_path(), event.test_name()], Color.antiquewhite)
				_print_status(event)
			
			GdUnitEvent.TESTSUITE_AFTER:
				_print_status(event)
				_console.prints_color("	| %d total | %d error | %d failed | %d skipped | %d orphans |\n" % [_report.test_count(), _report.error_count(), _report.failure_count(), _report.skipped_count(), _report.orphan_count()], Color.antiquewhite)
	
	func _print_status(event :GdUnitEvent) -> void:
		if event.is_skipped():
			_console.print_color("SKIPPED", Color.goldenrod, CmdConsole.BOLD|CmdConsole.ITALIC)
		elif event.is_failed() or event.is_error():
			_console.print_color("FAILED", Color.crimson, CmdConsole.BOLD)
		elif event.orphan_nodes() > 0:
			_console.print_color("PASSED", Color.goldenrod, CmdConsole.BOLD|CmdConsole.UNDERLINE)
		else:
			_console.print_color("PASSED", Color.forestgreen, CmdConsole.BOLD)
		_console.prints_color(" %s" % LocalTime.elapsed(event.elapsed_time()), Color.cornflower)

func _initialize():
	root.add_child(CLIRunner.new())

func _progress_test():
	var bar = ""
	var console := CmdConsole.new()
	#warning-ignore:return_value_discarded
	console.scrollArea(0, 30)
	
	for i in 100:
		bar += "#"
		#warning-ignore:return_value_discarded
		console.row_pos(30)
		# simulate standard console output
		prints("plalala %d" % i)
		#warning-ignore:return_value_discarded
		console.row_pos(38).print("")\
			.row_pos(39).print("------------------------------------------------------------------")\
			.row_pos(40).color(93).print( "[%-100s][%d]" % [bar, i])
	#warning-ignore:return_value_discarded
	console.reset()
	quit(0)

class_name GdUnitRunnerConfig
extends Resource

const CONFIG_VERSION = "1.0"
const VERSION = "version"
const INCLUDED = "included"
const SKIPPED = "skipped"
const SERVER_PORT = "server_port"
const EXIT_FAIL_FAST ="exit_on_first_fail"

const CONFIG_FILE = "res://GdUnitRunner.cfg"

var _config := {
		VERSION : CONFIG_VERSION,
		# a set of directories or testsuite paths as key and a optional set of testcases as values
		INCLUDED :  Dictionary(),
		# a set of skipped directories or testsuite paths
		SKIPPED : Dictionary(),
		# the port of running test server for this session
		SERVER_PORT : -1
	}

func clear() -> GdUnitRunnerConfig:
	_config[INCLUDED] = Dictionary()
	_config[SKIPPED] = Dictionary()
	return self

func set_server_port(port :int) -> GdUnitRunnerConfig:
	_config[SERVER_PORT] = port
	return self

func server_port() -> int:
	return _config.get(SERVER_PORT, -1)

func self_test() -> GdUnitRunnerConfig:
	add_test_suite("res://addons/gdUnit3/test/")
	add_test_suite("res://addons/gdUnit3/mono/test/")
	return self

func add_test_suite(resource_path :String) -> GdUnitRunnerConfig:
	var to_execute := to_execute()
	to_execute[resource_path] = to_execute.get(resource_path, Array())
	return self

func add_test_suites(resource_paths :PoolStringArray) -> GdUnitRunnerConfig:
	for resource_path in resource_paths:
		add_test_suite(resource_path)
	return self

func add_test_case(resource_path :String, test_name :String) -> GdUnitRunnerConfig:
	var to_execute := to_execute()
	var test_cases :Array = to_execute.get(resource_path, Array())
	test_cases.append(test_name)
	to_execute[resource_path] = test_cases
	return self

# supports full path or suite name with optional test case name
# <test_suite_name|path>[:<test_case_name>]
# '/path/path', res://path/path', 'res://path/path/testsuite.gd' or 'testsuite'
# 'res://path/path/testsuite.gd:test_case' or 'testsuite:test_case'
func skip_test_suite(value :String) -> GdUnitRunnerConfig:
	var parts :Array =  GdUnitTools.make_qualified_path(value).rsplit(":")
	if parts[0] == "res":
		parts.pop_front()
	parts[0] = GdUnitTools.make_qualified_path(parts[0])
	match parts.size():
		1: skipped()[parts[0]] = Array()
		2: skip_test_case(parts[0], parts[1])
	return self

func skip_test_suites(resource_paths :PoolStringArray) -> GdUnitRunnerConfig:
	for resource_path in resource_paths:
		skip_test_suite(resource_path)
	return self

func skip_test_case(resource_path :String, test_name :String) -> GdUnitRunnerConfig:
	var to_ignore := skipped()
	var test_cases :Array = to_ignore.get(resource_path, Array())
	test_cases.append(test_name)
	to_ignore[resource_path] = test_cases
	return self

func to_execute() -> Dictionary:
	return _config.get(INCLUDED, {"res://" : []})

func skipped() -> Dictionary:
	return _config.get(SKIPPED, Array())

func save(path :String = CONFIG_FILE) -> Result:
	var file := File.new()
	var err := file.open(path, File.WRITE)
	if err != OK:
		return Result.error("Can't write test runner configuration '%s'! %s" % [path, GdUnitTools.error_as_string(err)])
	_config[VERSION] = CONFIG_VERSION
	file.store_string(to_json(_config))
	file.close()
	return Result.success(path)

func load(path :String = CONFIG_FILE) -> Result:
	if not Directory.new().file_exists(path):
		return Result.error("Can't find test runner configuration '%s'! Please select a test to run." % path)
		
	var file := File.new()
	var err := file.open(path, File.READ)
	if err != OK:
		return Result.error("Can't load test runner configuration '%s'! ERROR: %s." % [path, GdUnitTools.error_as_string(err)])
	var content := file.get_as_text()
	if not content.empty() and content[0] == '{':
		# Parse as json
		var result := JSON.parse(content)
		if result.error != OK:
			return Result.error("The runner configuration '%s' is invalid! The format is changed please delete it manually and start a new test run." % path)
		_config = result.result as Dictionary
	else:
		# fallback to old format
		_config = file.get_var() as Dictionary
	if not _config.has(VERSION):
		return Result.error("The runner configuration '%s' is invalid! The format is changed please delete it manually and start a new test run." % path)
	file.close()
	return Result.success(path)

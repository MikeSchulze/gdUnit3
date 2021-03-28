class_name GdUnitRunnerConfig
extends Resource

const INCLUDED = "included"
const EXCLUDED = "ignored"
const SERVER_PORT = "server_port"
const EXIT_FAIL_FAST ="exit_on_first_fail"
const CONFIG_FILE = "res://GdUnitRunner.cfg"

var _config := {
		# a set of directories or testsuite paths as key and a optional set of testcases as values
		INCLUDED :  Dictionary(),
		# a set of excluded directories or testsuite paths
		EXCLUDED : Dictionary(),
		# the port of running test server for this session
		SERVER_PORT : -1
	}

func clear() -> GdUnitRunnerConfig:
	_config[INCLUDED] = Dictionary()
	_config[EXCLUDED] = Dictionary()
	return self

func set_server_port(port :int) -> GdUnitRunnerConfig:
	_config[SERVER_PORT] = port
	return self

func server_port() -> int:
	return _config.get(SERVER_PORT, -1)

func self_test() -> GdUnitRunnerConfig:
	add_test_suite("res://addons/gdUnit3/test/")
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

func ignore_test_suite(resource_path :String) -> GdUnitRunnerConfig:
	to_ignore()[resource_path] = Array()
	return self

func ignore_test_case(resource_path :String, test_name :String) -> GdUnitRunnerConfig:
	var to_ignore := to_ignore()
	var test_cases :Array = to_ignore.get(resource_path, Array())
	test_cases.append(test_name)
	to_ignore[resource_path] = test_cases
	return self

func to_execute() -> Dictionary:
	return _config.get(INCLUDED, {"res://" : []})

func to_ignore() -> Dictionary:
	return _config.get(EXCLUDED, [])

func save(path :String = CONFIG_FILE) -> Result:
	var file := File.new()
	var err := file.open(path, File.WRITE)
	if err != OK:
		return Result.error("Can't write test runner configuration '%s'! %s" % [path, GdUnitTools.error_as_string(err)])
	file.store_var(_config)
	file.close()
	return Result.success(path)

func load(path :String = CONFIG_FILE) -> Result:
	var file := File.new()
	var err := file.open(path, File.READ)
	match err:
		OK:
			pass
		ERR_FILE_NOT_FOUND:
			return Result.error("Can't find test runner configuration '%s'! Please select a test to run." % path)
		_:
			return Result.error("Can't load test runner configuration '%s'! ERROR: %s." % [path, GdUnitTools.error_as_string(err)])
	_config = file.get_var() as Dictionary
	file.close()
	return Result.success(path)

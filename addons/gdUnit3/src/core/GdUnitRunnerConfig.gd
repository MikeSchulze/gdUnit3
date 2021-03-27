class_name GdUnitRunnerConfig
extends Resource

const VERSION = "version"
const SELECTED = "selected"
const IGNORED = "ignored"
const EXIT_FAIL_FAST ="exit_on_first_fail"
const CONFIG_FILE = "res://addons/gdUnit3/GdUnitRunner.cfg"

var _config := {
		VERSION : "1.0",
		# a set of directories or testsuite paths as key and a optional set of testcases as values
		SELECTED : Dictionary(),
		IGNORED : Dictionary(),
	}

func self_test() -> void:
	add_test_suite("res://addons/gdUnit3/test/")

func add_test_suite(resource_path :String) -> void:
	var to_execute := to_execute()
	to_execute[resource_path] = to_execute.get(resource_path, Array())

func add_test_suites(resource_paths :PoolStringArray) -> void:
	for resource_path in resource_paths:
		add_test_suite(resource_path)

func add_test_case(resource_path :String, test_name :String) -> void:
	var to_execute := to_execute()
	var test_cases :Array = to_execute.get(resource_path, Array())
	test_cases.append(test_name)
	to_execute[resource_path] = test_cases

func ignore_test_suite(resource_path :String) -> void:
	to_ignore()[resource_path] = Array()

func ignore_test_case(resource_path :String, test_name :String) -> void:
	to_ignore().get(resource_path,  Array()).append(test_name)

func to_execute() -> Dictionary:
	return _config.get(SELECTED, {"res://addons/gdUnit3/test/" : []})

func to_ignore() -> Dictionary:
	return _config.get(IGNORED, [])

func save(path :String = CONFIG_FILE) -> void:
	var file := File.new()
	file.open(CONFIG_FILE, File.WRITE)
	file.store_var(_config)
	file.close()

func load(path :String = CONFIG_FILE) -> Result:
	var file := File.new()
	var err := file.open(path, File.READ)
	if err != OK:
		return Result.error("Can't find test runner configuration '%s'! Please select a test to run." % path)
	_config = file.get_var() as Dictionary
	# if old file format than convert into new format
	if not _config.has("VERSION"):
		return Result.error("The runner configuration '%s' is invalid! The format is changed please delete it manually and start a new test run." % path)
	file.close()
	return Result.success(true)

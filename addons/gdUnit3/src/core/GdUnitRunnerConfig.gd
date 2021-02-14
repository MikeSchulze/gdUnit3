class_name GdUnitRunnerConfig
extends Resource


# defines is the runner started in debug mode or not, true, false
const DEBUG_MODE = "debug_mode"
const SELECTED_TEST_SUITE_RESOURCES = "test_suites"
const SELECTED_TEST_CASE = "test_case"
const CONFIG_FILE = "res://addons/gdUnit3/GdUnitRunner.cfg"

static func save_config(config:Dictionary) -> void:
	var file := File.new()
	file.open(CONFIG_FILE, File.WRITE)
	file.store_var(config)
	file.close()
	
static func load_config() -> Dictionary:
	var file := File.new()
	var err := file.open(CONFIG_FILE, File.READ)
	if err != OK:
		push_error("Can't find test runner config! Please select a test to run.")
		return Dictionary()
	var config := file.get_var() as Dictionary
	file.close()
	return config


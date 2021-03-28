# GdUnit generated TestSuite
class_name GdUnitRunnerConfigTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitRunnerConfig.gd'

func test_initial_config():
	var config := GdUnitRunnerConfig.new()
	assert_dict(config._config[GdUnitRunnerConfig.INCLUDED]).is_empty()
	assert_dict(config._config[GdUnitRunnerConfig.EXCLUDED]).is_empty()

func test_clear_on_initial_config():
	var config := GdUnitRunnerConfig.new()
	config.clear()
	assert_dict(config._config[GdUnitRunnerConfig.INCLUDED]).is_empty()
	assert_dict(config._config[GdUnitRunnerConfig.EXCLUDED]).is_empty()

func test_clear_on_filled_config():
	var config := GdUnitRunnerConfig.new()
	config.add_test_suite("res://foo")
	config.ignore_test_suite("res://bar")
	assert_dict(config._config[GdUnitRunnerConfig.INCLUDED]).is_not_empty()
	assert_dict(config._config[GdUnitRunnerConfig.EXCLUDED]).is_not_empty()
	
	# clear it
	config.clear()
	assert_dict(config._config[GdUnitRunnerConfig.INCLUDED]).is_empty()
	assert_dict(config._config[GdUnitRunnerConfig.EXCLUDED]).is_empty()

func test_set_server_port():
	var config := GdUnitRunnerConfig.new()
	# intial value
	assert_int(config.server_port()).is_equal(-1)
	
	config.set_server_port(1000)
	assert_int(config.server_port()).is_equal(1000)

func test_self_test():
	var config := GdUnitRunnerConfig.new()
	# initial is empty
	assert_dict(config.to_execute()).is_empty()
	
	# configure self test
	var to_execute := config.self_test().to_execute()
	assert_dict(to_execute).contains_key_value("res://addons/gdUnit3/test/", [])

func test_add_test_suite():
	var config := GdUnitRunnerConfig.new()
	# ignore should have no affect
	config.ignore_test_suite("res://bar")
	
	config.add_test_suite("res://foo")
	assert_dict(config.to_execute()).contains_key_value("res://foo", [])
	# add two more
	config.add_test_suite("res://foo2")
	config.add_test_suite("res://bar/foo")
	assert_dict(config.to_execute())\
		.contains_key_value("res://foo", [])\
		.contains_key_value("res://foo2", [])\
		.contains_key_value("res://bar/foo", [])\

func test_add_test_suites():
	var config := GdUnitRunnerConfig.new()
	# ignore should have no affect
	config.ignore_test_suite("res://bar")
	
	config.add_test_suites(PoolStringArray(["res://foo2", "res://bar/foo", "res://foo1"]))
	
	assert_dict(config.to_execute())\
		.contains_key_value("res://foo1", [])\
		.contains_key_value("res://foo2", [])\
		.contains_key_value("res://bar/foo", [])\

func test_add_test_case():
	var config := GdUnitRunnerConfig.new()
	# ignore should have no affect
	config.ignore_test_suite("res://bar")
	
	config.add_test_case("res://foo1", "testcaseA")
	assert_dict(config.to_execute()).contains_key_value("res://foo1", ["testcaseA"])
	# add two more
	config.add_test_case("res://foo1", "testcaseB")
	config.add_test_case("res://foo2", "testcaseX")
	assert_dict(config.to_execute())\
		.contains_key_value("res://foo1", ["testcaseA", "testcaseB"])\
		.contains_key_value("res://foo2", ["testcaseX"])

func test_add_test_suites_and_test_cases_combi():
	var config := GdUnitRunnerConfig.new()
	
	config.add_test_suite("res://foo1")
	config.add_test_suite("res://foo2")
	config.add_test_suite("res://bar/foo")
	config.add_test_case("res://foo1", "testcaseA")
	config.add_test_case("res://foo1", "testcaseB")
	config.add_test_suites(PoolStringArray(["res://foo3", "res://bar/foo3", "res://foo4"]))
	
	assert_dict(config.to_execute())\
		.has_size(6)\
		.contains_key_value("res://foo1", ["testcaseA", "testcaseB"])\
		.contains_key_value("res://foo2", [])\
		.contains_key_value("res://foo3", [])\
		.contains_key_value("res://foo4", [])\
		.contains_key_value("res://bar/foo3", [])\
		.contains_key_value("res://bar/foo", [])

func test_ignore_test_suite():
	var config := GdUnitRunnerConfig.new()
	
	config.ignore_test_suite("res://foo1")
	assert_dict(config.to_ignore()).contains_key_value("res://foo1", [])
	# add two more
	config.ignore_test_suite("res://foo2")
	config.ignore_test_suite("res://bar/foo1")
	assert_dict(config.to_ignore())\
		.contains_key_value("res://foo1", [])\
		.contains_key_value("res://foo2", [])\
		.contains_key_value("res://bar/foo1", [])

func test_ignore_test_case():
	var config := GdUnitRunnerConfig.new()
	
	config.ignore_test_case("res://foo1", "testcaseA")
	assert_dict(config.to_ignore()).contains_key_value("res://foo1", ["testcaseA"])
	# add two more
	config.ignore_test_case("res://foo1", "testcaseB")
	config.ignore_test_case("res://foo2", "testcaseX")
	assert_dict(config.to_ignore())\
		.contains_key_value("res://foo1", ["testcaseA", "testcaseB"])\
		.contains_key_value("res://foo2", ["testcaseX"])

func test_load_fail():
	var config := GdUnitRunnerConfig.new()
	
	assert_result(config.load("invalid_path"))\
		.is_error()\
		.contains_message("Can't find test runner configuration 'invalid_path'! Please select a test to run.")

func test_save_load():
	var config := GdUnitRunnerConfig.new()
	# add some dummy conf
	config.set_server_port(1000)
	config.ignore_test_suite("res://bar")
	config.add_test_suite("res://foo2")
	config.add_test_case("res://foo1", "testcaseA")
	
	var config_file := create_temp_dir("test_save_load") + "/testconf.cfg"

	assert_result(config.save(config_file)).is_success()
	assert_file(config_file).exists()
	
	var config2 := GdUnitRunnerConfig.new()
	assert_result(config2.load(config_file)).is_success()
	# verify the config has original enties
	assert_object(config2).is_equal(config).is_not_same(config)

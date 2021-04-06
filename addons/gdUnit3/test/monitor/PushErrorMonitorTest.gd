# GdUnit generated TestSuite
class_name PushErrorMonitorTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/monitor/PushErrorMonitor.gd'

func before():
	# disable temporary the global push_error_monitor ohterwise it will be collidated
	# with this test cases
	Engine.set_meta("gdUnit_push_error_monitor_enabled", false)

func after():
	Engine.set_meta("gdUnit_push_error_monitor_enabled", false)
	#clear_push_errors()

func _test_start_no_errors():
	var monitor = PushErrorMonitor.new()
	# no errors after initalized monitor
	var errors = yield(monitor.list_errors(), "completed")
	assert_array(errors).is_empty()
	
	# start and stop monitoring
	yield(monitor.start(), "completed")
	yield(monitor.stop(), "completed")
	# should not collected any errors in this time
	errors = yield(monitor.list_errors(), "completed")
	assert_array(errors).is_empty()

func _test_start_with_errors():
	push_error("this is a test error 1")
	push_error("this is a test error 2")
	push_error("this is a test error 3")
	push_error("this is a test error 4")
	yield(get_tree(), "idle_frame")
	var monitor = PushErrorMonitor.new()

	yield(monitor.start(), "completed")
	# simulate an error
	push_error("this is a test error for test")
	yield(monitor.stop(), "completed")
	
	# check if the monitor has collected the error
	var errors = yield(monitor.list_errors(), "completed")
	assert_array(errors).has_size(1)
	var error = errors[0]
	# TODO implement dictionary assert support
	#assert_dict(error).contains("is_error", true)
	#assert_dict(error).contains("message", "call: this is a test error")
	#assert_dict(error).contains("meta", ["res://addons/gdUnit3/test/monitor/PushErrorMonitorTest.gd", 35])

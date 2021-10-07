class_name GdUnitFuncAssertImpl
extends GdUnitFuncAssert

signal value_provided(value)
const DEFAULT_TIMEOUT := 2000

var _current_value_provider :ValueProvider
var _current_error_message = null
var _custom_failure_message = null
var _line_number := -1
var _expect_fail := false
var _is_failed := false
var _timeout := DEFAULT_TIMEOUT
var _expect_result :int
var _report_consumer : GdUnitReportConsumer
var _caller : WeakRef
var _interrupted := false
var _fs :GDScriptFunctionState = null

func _init(caller :WeakRef, instance :Object, func_name :String, args := Array(), expect_result := EXPECT_SUCCESS):
	_line_number = GdUnitAssertImpl._get_line_number()
	_expect_result = expect_result
	_caller = caller
	GdAssertReports.reset_last_error_line_number()
	# set report consumer to be use to report the final result
	_report_consumer = caller.get_ref().get_meta(GdUnitReportConsumer.META_PARAM)
	# we expect the test will fail
	if expect_result == EXPECT_FAIL:
		_expect_fail = true
	# verify at first the function name exists
	if not instance.has_method(func_name):
		report_error("The function '%s' do not exists on instance '%s'." % [func_name, instance])
	else:
		_current_value_provider = CallBackValueProvider.new(instance, func_name, args)

func report_success() -> GdUnitAssert:
	return GdAssertReports.report_success(self)

func report_error(error_message :String) -> GdUnitAssert:
	if _custom_failure_message == null:
		return GdAssertReports.report_error(error_message, self, _line_number)
	return GdAssertReports.report_error(_custom_failure_message, self, _line_number)

func send_report(report :GdUnitReport)-> void:
	if is_instance_valid(_report_consumer):
		_report_consumer.consume(report)

# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitFuncAssert:
	var current_error := _extract_plain_message(_current_error_message)
	if current_error != expected:
		_expect_fail = false
		var diffs := GdObjects.string_diff(current_error, expected)
		var current := GdAssertMessages.colorDiff(diffs[1])
		_custom_failure_message = null
		report_error(GdAssertMessages.error_not_same_error(current, expected))
	return self

func starts_with_failure_message(expected: String) -> GdUnitFuncAssert:
	var current_error := _extract_plain_message(_current_error_message)
	if not current_error.begins_with(expected):
		_expect_fail = false
		var diffs := GdObjects.string_diff(current_error, expected)
		var current := GdAssertMessages.colorDiff(diffs[1])
		_custom_failure_message = null
		report_error(GdAssertMessages.error_not_same_error(current, expected))
	return self

func _extract_plain_message(message) -> String:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.parse_bbcode(message if message else "")
	rtl.queue_free()
	return rtl.get_text()

func override_failure_message(message :String) -> GdUnitAssert:
	_custom_failure_message = message
	return self

func wait_until(timeout := 2000) -> GdUnitAssert:
	if timeout <= 0:
		push_warning("Invalid timeout param, alloed timeouts must be grater than 0. Use default timeout instead")
		_timeout = DEFAULT_TIMEOUT
	else:
		_timeout = timeout
	return self

func is_null() -> GdUnitAssert:
	return _validate_callback("is_null")

func is_not_null() -> GdUnitAssert:
	return _validate_callback("is_not_null")

func is_false() -> GdUnitAssert:
	return _validate_callback("is_false")

func is_true() -> GdUnitAssert:
	return _validate_callback("is_true")

func is_equal(expected) -> GdUnitAssert:
	return _validate_callback("is_equal", expected)

func is_not_equal(expected) -> GdUnitAssert:
	return _validate_callback("is_not_equal", expected)

# -------- assert implementations
func _is_null(current, expected) -> bool:
	return current == null

func _is_not_null(current, expected) -> bool:
	return current != null

func _is_equal(current, expected) -> bool:
	return GdObjects.equals(current, expected)

func _is_not_equal(current, expected) -> bool:
	return not GdObjects.equals(current, expected)

func _is_true(current, expected) -> bool:
	return current == true

func _is_false(current, expected) -> bool:
	return current == false

func _validate_callback(func_name :String, expected = null):
	# if initial failed?
	if _is_failed:
		yield(Engine.get_main_loop(), "idle_frame")
		return self
	var caller = _caller.get_ref()
	var assert_cb = funcref(self, "_" + func_name)
	var time_scale = Engine.get_time_scale()
	var timeout = Timer.new()
	caller.add_child(timeout)
	timeout.set_one_shot(true)
	timeout.connect("timeout", self, "_on_timeout")
	timeout.start((_timeout/1000.0)*time_scale)
	# sleep timer
	var sleep := Timer.new()
	caller.add_child(sleep)
	_interrupted = false
	
	while true:
		var current = yield(next_current_value(), "value_provided")
		if _interrupted:
			break
		var is_success = assert_cb.call_func(current, expected)
		
		if _expect_result != EXPECT_FAIL and is_success:
			break
		sleep.start(0.05)
		yield(sleep, "timeout")
	
	sleep.stop()
	sleep.queue_free()
	timeout.queue_free()
	#if caller deleted? the test is intrrupted by a timeout
	if not is_instance_valid(caller):
		dispose(_fs)
		return
	if _interrupted:
		report_error(GdAssertMessages.error_interrupted(func_name, expected, LocalTime.elapsed(_timeout)))
	else:
		report_success()
	dispose(_fs)
	return self

func next_current_value():
	var current = _current_value_provider.get_value()
	if current is GDScriptFunctionState:
		_fs = current
		if not current.is_connected("completed", self, "_on_completed"):
			current.connect("completed", self, "_on_completed")
	else:
		call_deferred("emit_signal", "value_provided", current)
	return self

func _on_completed(value):
	call_deferred("emit_signal", "value_provided", value)

func _on_timeout():
	_interrupted = true
	call_deferred("emit_signal", "value_provided", null)

# it is important to free all references/connections to prevent orphan nodes
func dispose(fs :GDScriptFunctionState):
	disconnect_connections(fs)
	disconnect_connections(self)
	_caller = null
	_current_value_provider = null

func disconnect_connections(obj :Object):
	if is_instance_valid(obj):
		# disconnect from all connected signals to force freeing, otherwise it ends up in orphans
		for connection in obj.get_incoming_connections():
			var source_ :Object = connection["source"]
			var signal_ :String = connection["signal_name"]
			var method_name_ :String = connection["method_name"]
			source_.disconnect(signal_, obj, method_name_)

class_name GdUnitFuncAssertImpl
extends GdUnitFuncAssert

signal completed

class FailureCollector:
	var _failure := false
	
	func set_error() -> void:
		_failure = true
	
	func clear():
		_failure = false
	
	func has_error() -> bool:
		return _failure

var _current_value_provider :ValueProvider
var _current_error_message = null
var _custom_failure_message = null
var _line_number := -1
var _expect_fail := false
var _is_failed := false
# default timeout 2s
var _default_timeout : int = 2000
var _expect_result :int
var _failure_collector := FailureCollector.new()
var _report_consumer : GdUnitReportConsumer
var _caller : WeakRef
var _interrupted := false


func _init(caller :WeakRef, instance :Object, func_name :String, args := Array(), expect_result := EXPECT_SUCCESS):
	_line_number = GdUnitAssertImpl._get_line_number()
	_expect_result = expect_result
	_caller = caller
	# set report consumer to be use to report the final result
	_report_consumer = caller.get_ref().get_meta(GdUnitReportConsumer.META_PARAM)
	_current_value_provider =  CallBackValueProvider.new(instance, func_name, args)
	# we expect the test will fail
	if expect_result == EXPECT_FAIL:
		_expect_fail = true

func __current():
	return _current_value_provider.get_value()

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
func has_failure_message(expected: String) -> GdUnitAssert:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.parse_bbcode(_current_error_message)
	var current_error := rtl.get_text()
	rtl.free()
	if current_error != expected:
		_expect_fail = false
		var diffs := GdObjects.string_diff(current_error, expected)
		var current := GdAssertMessages.colorDiff(diffs[1])
		_custom_failure_message = null
		report_error(GdAssertMessages.error_not_same_error(current, expected))
	return self

func override_failure_message(message :String) -> GdUnitAssert:
	_custom_failure_message = message
	return self

func wait_until(timeout := 2000) -> GdUnitAssert:
	if timeout <= 0:
		push_warning("Invalid timeout param, alloed timeouts must be grater than 0. Use default timeout instead")
		_default_timeout = _default_timeout
	else:
		_default_timeout = timeout
	return self

func is_null() -> GdUnitAssert:
	return _validate_callback("is_null")

func is_not_null() -> GdUnitAssert:
	return _validate_callback("is_not_null")

func is_false() -> GdUnitAssert:
	return _validate_callback("is_false")

func is_true() -> GdUnitAssert:
	return _validate_callback("is_true")

func is_equal(value) -> GdUnitAssert:
	return _validate_callback("is_equal", [value])

func is_not_equal(value) -> GdUnitAssert:
	return _validate_callback("is_not_equal", [value])

# -------- assert implementations
func _is_null() -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		return current
	if current != null:
		_failure_collector.set_error()
	return self

func _is_not_null() -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		return current
	if current == null:
		_failure_collector.set_error()
	return self

func _is_equal(expected) -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		current = yield(current, "completed")
		#return current
	if not GdObjects.equals(current, expected):
		_failure_collector.set_error()
	return self

func _is_not_equal(expected) -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		return current
	if GdObjects.equals(current, expected):
		_failure_collector.set_error()
	return self

func _is_true() -> GdUnitAssert:
	if __current() != true:
		_failure_collector.set_error()
	return self

func _is_false() -> GdUnitAssert:
	if __current() == true:
		_failure_collector.set_error()
	return self

func _validate_callback(func_name :String, args = Array()):
	var assert_cb = funcref(self, "_" + func_name)
	var timeout = Timer.new()
	var caller = _caller.get_ref()
	var fs :GDScriptFunctionState = null
	_interrupted = false
	caller.add_child(timeout)
	timeout.set_one_shot(true)
	timeout.connect("timeout", self, "_on_timeout", [null])
	timeout.start(_default_timeout/1000.0)
	# sleep timer
	var sleep := Timer.new()
	caller.add_child(sleep)
	while not _interrupted:
		_failure_collector.clear()
		if args.empty():
			fs = execute(assert_cb.call_func())
		else:
			fs = execute(assert_cb.call_funcv(args))
		if fs is GDScriptFunctionState:
			timeout.disconnect("timeout", self, "_on_timeout")
			timeout.connect("timeout", self, "_on_timeout", [fs])
			if not fs.is_connected("completed", self, "_on_completed"):
				fs.connect("completed", self, "_on_completed")
		yield(self, "completed")
		if _expect_result != EXPECT_FAIL and not _failure_collector.has_error():
			break
		sleep.start(0.05)
		yield(sleep, "timeout")
	
	sleep.stop()
	sleep.queue_free()
	timeout.queue_free()
	#if caller deleted? the test is intrrupted by a timeout
	if not is_instance_valid(caller):
		dispose()
		return
	if _interrupted:
		report_error(GdAssertMessages.error_interrupted(func_name, args, LocalTime.elapsed(_default_timeout)))
	else:
		report_success()
	dispose()
	return self

func execute(value):
	if value is GDScriptFunctionState:
		return value
	call_deferred("emit_signal", "completed")

func _on_completed(value):
	prints("_on_completed", value)
	emit_signal("completed")

func _on_timeout(fs :GDScriptFunctionState):
	_interrupted = true
	if fs != null:
		fs.emit_signal("completed", fs)

func dispose():
	prints("dispose", self)
	_caller = null
	_current_value_provider = null
	_report_consumer = null
	notification(NOTIFICATION_PREDELETE)

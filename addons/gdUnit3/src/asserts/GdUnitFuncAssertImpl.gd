class_name GdUnitFuncAssertImpl
extends GdUnitFuncAssert

signal completed

class ReportCollector extends GdUnitReportConsumer:
	var _reports = Array()
	
	func consume(report :GdUnitReport) -> void:
		_reports.append(report)
	
	func clear():
		_reports.clear()
	
	func has_error() -> bool:
		return not _reports.empty()
	
	func report() -> GdUnitReport:
		return _reports[-1] if not _reports.empty() else null

# default timeout 2s
var _default_timeout : int = 2000
var _expect :int
var _report_consumer : ReportCollector
var _assert : GdUnitAssert
var _caller : WeakRef
var _original_report_consumer :WeakRef
var _interrupted := false

func _init(caller :Node, instance :Object, func_name :String, args := Array(), expect := EXPECT_SUCCESS):
	_expect = expect
	_caller = weakref(caller)
	# save current report consumer to be use to report the final result
	_original_report_consumer = weakref(caller.get_meta(GdUnitReportConsumer.META_PARAM))
	# assign a new report collector to catch all reports
	_report_consumer = ReportCollector.new()
	set_meta(GdUnitReportConsumer.META_PARAM, _report_consumer)
	_assert = create_assert_by_return_type(self, instance, func_name, args, expect)
	if _assert is GdUnitAssertImpl:
		_assert.set_line_number(GdUnitAssertImpl._get_line_number())
	else:
		_assert._base.set_line_number(GdUnitAssertImpl._get_line_number())

# -------- Base Assert wrapping ------------------------------------------------
func set_report_consumer(report_consumer :WeakRef) -> void:
	if _assert is GdUnitAssertImpl:
		_assert._report_consumer = report_consumer
	else:
		_assert._base._report_consumer = report_consumer

func has_failure_message(expected: String) -> GdUnitAssert:
	_assert.has_failure_message(expected)
	return self

func override_failure_message(message :String) -> GdUnitAssert:
	_assert.override_failure_message(message)
	return self

static func create_assert_by_return_type(caller :Object, instance :Object, func_name :String, args := Array(),  expect := EXPECT_SUCCESS) -> GdUnitAssert:
	var value_provider := CallBackValueProvider.new(instance, func_name, args)
	var return_type := get_return_type(instance, func_name)
	if GdObjects.is_array_type(return_type):
		return GdUnitArrayAssertImpl.new(caller, value_provider, expect)
	
	match return_type:
		TYPE_BOOL:
			return GdUnitBoolAssertImpl.new(caller, value_provider, expect)
		TYPE_INT:
			return GdUnitIntAssertImpl.new(caller, value_provider, expect)
		TYPE_REAL:
			return GdUnitFloatAssertImpl.new(caller, value_provider, expect)
		TYPE_STRING:
			return GdUnitStringAssertImpl.new(caller, value_provider, expect)
		TYPE_ARRAY:
			return GdUnitArrayAssertImpl.new(caller, value_provider, expect)
		TYPE_DICTIONARY:
			return GdUnitDictionaryAssertImpl.new(caller, value_provider, expect)
		TYPE_OBJECT:
			return GdUnitObjectAssertImpl.new(caller, value_provider, expect)
		TYPE_VECTOR2:
			return GdUnitVector2AssertImpl.new(caller, value_provider, expect)
		TYPE_VECTOR3:
			return GdUnitVector3AssertImpl.new(caller, value_provider, expect)
		TYPE_NIL:
			return  GdUnitAssertImpl.new(caller, value_provider, expect);
	return  null;

static func get_return_type(instance :Object, func_name :String) -> int:
	if instance.get_script() is GDScript:
		for method in instance.get_script().get_script_method_list():
			if method["name"] == func_name:
				return method["return"]["type"]
	else: 
		for method in instance.get_method_list():
			if method["name"] == func_name:
				return method["return"]["type"]
	return TYPE_NIL

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
	
func _validate_callback(func_name :String, args = Array()):
	var assert_cb = funcref(_assert, func_name)
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
		_report_consumer.clear()
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
		if _expect != EXPECT_FAIL and not _report_consumer.has_error():
			break
		sleep.start(0.05)
		yield(sleep, "timeout")
	
	sleep.stop()
	sleep.queue_free()
	timeout.queue_free()
	#if caller deleted? the test is intrrupted by a timeout
	if not is_instance_valid(caller):
		return
	set_report_consumer(_original_report_consumer)
	if _interrupted:
		if not args.empty():
			_assert.report_error("Expected: %s '%s' but is interrupted after %s" % [func_name, args[-1], LocalTime.elapsed(_default_timeout)])
		else:
			_assert.report_error("Expected: %s but is interrupted after %s" % [func_name, LocalTime.elapsed(_default_timeout)])
		return self
	if _report_consumer.has_error():
		var report := _report_consumer.report()
		_assert.report_error(report.message())
	else:
		_assert.report_success()
	return self

func execute(value):
	if value is GDScriptFunctionState:
		return value
	call_deferred("emit_signal", "completed")

func _on_completed(value):
	emit_signal("completed")

func _on_timeout(fs :GDScriptFunctionState):
	#prints("assert timed out")
	_interrupted = true
	if fs != null:
		fs.emit_signal("completed", fs)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_report_consumer.clear()
		_report_consumer = null
		_original_report_consumer = null
		_caller = null
		_assert = null

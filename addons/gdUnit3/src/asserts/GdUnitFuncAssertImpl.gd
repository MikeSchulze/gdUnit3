class_name GdUnitFuncAssertImpl
extends GdUnitFuncAssert

class ReportCollector extends GdUnitReportConsumer:
	var _reports = Array()
	
	func consume(report :GdUnitReport) -> void:
		_reports.append(report)
	
	func clear():
		_reports.clear()
	
	func has_error() -> bool:
		return not _reports.empty()
	
	func report() -> GdUnitReport:
		return _reports[-1]

# default timeout 2s
var _default_timeout : int = 2000
var _expect :int
var _report_consumer : ReportCollector
var _assert : GdUnitAssert
var _caller : WeakRef
var _original_report_consumer :WeakRef

func _init(caller :Node, instance :Object, func_name :String, args := Array(), expect := EXPECT_SUCCESS):
	_expect = expect
	_caller = weakref(caller)
	# save current report consumer to be use to report the final result
	_original_report_consumer = weakref(caller.get_meta(GdUnitReportConsumer.META_PARAM))
	# assign a new report collector to catch all reports
	_report_consumer = ReportCollector.new()
	set_meta(GdUnitReportConsumer.META_PARAM, _report_consumer)
	_assert = create_assert_by_return_type(self, instance, func_name, args, expect)
	_assert._base.set_line_number(GdUnitAssertImpl._get_line_number())

# -------- Base Assert wrapping ------------------------------------------------
func set_report_consumer(report_consumer :WeakRef) -> void:
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
	var fr = funcref(_assert, "is_null")
	return _validate_callback(fr)

func is_not_null() -> GdUnitAssert:
	var fr = funcref(_assert, "is_not_null")
	return _validate_callback(fr)

func is_false() -> GdUnitAssert:
	var fr = funcref(_assert, "is_false")
	return _validate_callback(fr)

func is_true() -> GdUnitAssert:
	var fr = funcref(_assert, "is_true")
	return _validate_callback(fr)

func is_equal(value) -> GdUnitAssert:
	var fr = funcref(_assert, "is_equal")
	return _validate_callback(fr, [value])

func is_not_equal(value) -> GdUnitAssert:
	var fr = funcref(_assert, "is_not_equal")
	return _validate_callback(fr, [value])
	
func _validate_callback(assert_cb :FuncRef, args = Array()):
	var timeout = Timer.new()
	var caller = _caller.get_ref()
	caller.add_child(timeout)
	timeout.set_one_shot(true)
	timeout.start(_default_timeout/1000.0)
	# sleep timer
	var sleep := Timer.new()
	caller.add_child(sleep)
	
	while timeout.time_left > 0:
		_report_consumer.clear()
		if args.empty():
			assert_cb.call_func()
		else:
			assert_cb.call_funcv(args)
		if _expect != EXPECT_FAIL and not _report_consumer.has_error():
			break
		sleep.start(0.05)
		yield(sleep, "timeout")
	
	sleep.stop()
	sleep.queue_free()
	timeout.free()
	#if caller deleted? the test is intrrupted by a timeout
	if not is_instance_valid(caller):
		return
	set_report_consumer(_original_report_consumer)
	if _report_consumer.has_error():
		var report := _report_consumer.report()
		_assert.report_error(report.message())
	else:
		_assert.report_success()
	return self

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_report_consumer.clear()
		_report_consumer = null
		_original_report_consumer = null
		_caller = null
		_assert = null

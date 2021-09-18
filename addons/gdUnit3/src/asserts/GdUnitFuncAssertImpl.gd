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
var _wait_timeout : int = 2000
var _report_consumer : ReportCollector
var _assert : GdUnitAssert
var _caller : Node
var _original_report_consumer :WeakRef

func _init(caller :Node, instance :Object, func_name :String, args := Array(), expect := EXPECT_SUCCESS):
	_caller = caller
	# save current report consumer to be use to report the final result
	_original_report_consumer = weakref(caller.get_meta(GdUnitReportConsumer.META_PARAM))
	# assign a new report collector to catch all reports
	_report_consumer = ReportCollector.new()
	set_meta(GdUnitReportConsumer.META_PARAM, _report_consumer)
	_assert = create_assert_by_return_type(self, instance, func_name, args, expect)

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
	_wait_timeout = timeout
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
	var timer = Timer.new()
	_caller.add_child(timer)
	timer.set_one_shot(true)
	timer.start(_wait_timeout/1000)
	yield(_caller.get_tree(), "idle_frame")
	while timer.time_left > 0:
		_report_consumer.clear()
		if args.empty():
			assert_cb.call_func()
		else:
			assert_cb.call_funcv(args)
		if not _report_consumer.has_error():
			break
		yield(_caller.get_tree().create_timer(0.05), "timeout")
	_caller.remove_child(timer)
	timer.free()
	if _report_consumer.has_error():
		var report := _report_consumer.report()
		_original_report_consumer.get_ref().consume(report)
	else:
		_assert.report_success()
		
	dispose()
	return self

func dispose() -> void:
	_report_consumer.clear()
	_report_consumer = null
	_original_report_consumer = null
	_caller = null
	_assert = null

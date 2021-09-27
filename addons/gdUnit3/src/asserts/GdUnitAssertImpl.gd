class_name GdUnitAssertImpl
extends GdUnitAssert

var _current_value_provider :ValueProvider
var _is_failed :bool = false
var _current_error_message :String = ""
var _expect_fail :bool = false
var _custom_failure_message = null
var _report_consumer :WeakRef
var _line_number := -1

# Scans the current stack trace for the root cause to extract the line number
static func _get_line_number() -> int:
	var stack_trace := get_stack()
	if stack_trace == null or stack_trace.empty():
		return -1
	for stack_info in stack_trace:
		var function :String = stack_info.get("function")
		var source :String = stack_info.get("source")
		if source.ends_with("AssertImpl.gd") or source.ends_with("GdUnitTestSuite.gd"):
			continue
		return stack_info.get("line")
	return -1

func _init(caller :Object, current, expect_result :int = EXPECT_SUCCESS):
	assert(caller != null, "missing argument caller!")
	assert(caller.has_meta(GdUnitReportConsumer.META_PARAM), "caller must register a report consumer!")
	_report_consumer = weakref(caller.get_meta(GdUnitReportConsumer.META_PARAM))
	_current_value_provider = current if current is ValueProvider else DefaultValueProvider.new(current)
	# we expect the test will fail
	if expect_result == EXPECT_FAIL:
		_expect_fail = true

func set_line_number(line_number :int) -> void:
	_line_number = line_number

func __current():
	return _current_value_provider.get_value()

func __validate_value_type(value, type :int) -> bool:
	return value is ValueProvider or value == null or typeof(value) == type

func report_success() -> GdUnitAssert:
	return GdAssertReports.report_success(self)

func report_error(error_message :String) -> GdUnitAssert:
	var line_number := _line_number if _line_number != -1 else _get_line_number()
	if _custom_failure_message == null:
		return GdAssertReports.report_error(error_message, self, line_number)
	return GdAssertReports.report_error(_custom_failure_message, self, line_number)

func test_fail():
	return report_error(GdAssertMessages.error_not_implemented())

func has_failure_message(expected :String):
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.parse_bbcode(_current_error_message)
	var current_error := rtl.get_text()
	rtl.free()
	if current_error != expected:
		_expect_fail = false
		var diffs := GdObjects.string_diff(current_error, expected)
		var current := GdAssertMessages.colorDiff(diffs[1])
		report_error(GdAssertMessages.error_not_same_error(current, expected))
	return self

func starts_with_failure_message(expected :String):
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.parse_bbcode(_current_error_message)
	var current_error := rtl.get_text()
	rtl.free()
	if current_error.find(expected) != 0:
		_expect_fail = false
		var diffs := GdObjects.string_diff(current_error, expected)
		var current := GdAssertMessages.colorDiff(diffs[1])
		report_error(GdAssertMessages.error_not_same_error(current, expected))
	return self

func override_failure_message(message :String):
	_custom_failure_message = message
	return self

func is_equal(expected) -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		current = yield(current, "completed")
	if not GdObjects.equals(current, expected):
		return report_error(GdAssertMessages.error_equal(current, expected))
	return report_success()

func is_not_equal(expected) -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		return current
	if GdObjects.equals(current, expected):
		return report_error(GdAssertMessages.error_not_equal(current, expected))
	return report_success()

func is_null() -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		return current
	if current != null:
		return report_error(GdAssertMessages.error_is_null(current))
	return report_success()

func is_not_null() -> GdUnitAssert:
	var current = __current()
	if current is GDScriptFunctionState:
		return current
	if current == null:
		return report_error(GdAssertMessages.error_is_not_null())
	return report_success()

func send_report(report :GdUnitReport)-> void:
	var consumer = _report_consumer.get_ref()
	if is_instance_valid(consumer):
		consumer.consume(report)

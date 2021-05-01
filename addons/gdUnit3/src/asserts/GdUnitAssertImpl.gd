class_name GdUnitAssertImpl
extends GdUnitAssert

var _current
var _is_failed :bool = false
var _current_error_message :String = ""
var _expect_fail :bool = false
var _custom_error_message = null
var _error_info = null

# Scans the current stack trace for the root cause to extract the line number
static func _get_line_number() -> int:
	var stack_trace := get_stack()
	if stack_trace == null or stack_trace.empty():
		return -1
	
	var failure_line := -1
	while not stack_trace.empty():
		var stack_info = stack_trace.pop_front()
		var source :String = stack_info.get("function")
		if source == "execute_test_case":
			return failure_line
		failure_line = stack_info.get("line")
	# if no GdUnitExecutor in the stacktrace then is possible called in a yield stack
	var stack_info = get_stack()[-1]
	return stack_info.get("line")

func _init(current, expect_result :int = EXPECT_SUCCESS):
	_current = current
	# we expect the test will fail
	if expect_result == EXPECT_FAIL:
		_expect_fail = true

func report_success() -> GdUnitAssert:
	return GdAssertReports.report_success(self)

func report_error(error_message :String) -> GdUnitAssert:
	var line_number := _get_line_number()

	if _custom_error_message == null:
		var message := error_message
		if _error_info != null:
			message = _error_info + "\n" + error_message
		return GdAssertReports.report_error(message, self, line_number)
	return GdAssertReports.report_error(_custom_error_message, self, line_number)

func test_fail():
	return report_error(GdAssertMessages.error_not_implemented())

func has_error_message(expected :String):
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


func starts_with_error_message(expected :String):
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

func as_error_message(message :String):
	_custom_error_message = message
	return self

func with_error_info(message :String):
	_error_info = message
	return self

func is_equal(expected) -> GdUnitAssert:
	if not GdObjects.equals(_current, expected):
		return report_error(GdAssertMessages.error_equal(_current, expected))
	return report_success()

func is_not_equal(expected) -> GdUnitAssert:
	if GdObjects.equals(_current, expected):
		return report_error(GdAssertMessages.error_not_equal(_current, expected))
	return report_success()

func is_null() -> GdUnitAssert:
	if _current != null:
		return report_error(GdAssertMessages.error_is_null(_current))
	return report_success()

func is_not_null() -> GdUnitAssert:
	if _current == null:
		return report_error(GdAssertMessages.error_is_not_null())
	return report_success()

# is important to remove holding reference
func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		_current = null

class_name GdUnitStringAssertImpl
extends GdUnitStringAssert

var _base :GdUnitAssert

func _init(caller :Object, current, expect_result :int):
	_base = GdUnitAssertImpl.new(caller, current, expect_result)
	if typeof(current) != TYPE_STRING:
		report_error("GdUnitStringAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __current() -> String:
	if _base._current == null:
		return "<Null>"
	return _base._current as String

func report_success() -> GdUnitStringAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitStringAssert:
	_base.report_error(error)
	return self

# -------- Base Assert overloadings  -------------------------------------------
func has_error_message(expected: String) -> GdUnitStringAssert:
	_base.has_error_message(expected)
	return self

func as_error_message(message :String) -> GdUnitStringAssert:
	_base.as_error_message(message)
	return self

func starts_with_error_message(expected: String) -> GdUnitStringAssert:
	_base.starts_with_error_message(expected)
	return self

func with_error_info(message :String) -> GdUnitStringAssert:
	_base.with_error_info(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------
func is_equal(expected) -> GdUnitStringAssert:
	var current := __current()
	if not GdObjects.equals(current, expected):
		var diffs := GdObjects.string_diff(current, expected)
		var formatted_current := GdAssertMessages.colorDiff(diffs[1])
		return report_error(GdAssertMessages.error_equal(formatted_current, expected))
	return report_success()

func is_equal_ignoring_case(expected) -> GdUnitStringAssert:
	var current := __current()
	if not GdObjects.equals(current, expected, true):
		var diffs := GdObjects.string_diff(current, expected)
		var formatted_current := GdAssertMessages.colorDiff(diffs[1])
		return report_error(GdAssertMessages.error_equal_ignoring_case(formatted_current, expected))
	return report_success()

func is_not_equal(expected) -> GdUnitStringAssert:
	var current := __current()
	if GdObjects.equals(current, expected):
		return report_error(GdAssertMessages.error_not_equal(current, expected))
	return report_success()

func is_not_equal_ignoring_case(expected) -> GdUnitStringAssert:
	var current := __current()
	if GdObjects.equals(current, expected, true):
		return report_error(GdAssertMessages.error_not_equal(current, expected))
	return report_success()

func is_empty() -> GdUnitStringAssert:
	var current := __current()
	if not current.empty():
		return report_error(GdAssertMessages.error_is_empty(current))
	return report_success()

func is_not_empty() -> GdUnitStringAssert:
	var current := __current()
	if current.empty():
		return report_error(GdAssertMessages.error_is_not_empty())
	return report_success()

func contains(expected :String) -> GdUnitStringAssert:
	if __current().find(expected) == -1:
		return report_error(GdAssertMessages.error_contains(__current(), expected))
	return report_success()

func not_contains(expected :String) -> GdUnitStringAssert:
	if __current().find(expected) != -1:
		return report_error(GdAssertMessages.error_not_contains(__current(), expected))
	return report_success()

func contains_ignoring_case(expected :String) -> GdUnitStringAssert:
	if __current().findn(expected) == -1:
		return report_error(GdAssertMessages.error_contains_ignoring_case(__current(), expected))
	return report_success()

func not_contains_ignoring_case(expected :String) -> GdUnitStringAssert:
	if __current().findn(expected) != -1:
		return report_error(GdAssertMessages.error_not_contains_ignoring_case(__current(), expected))
	return report_success()

func starts_with(expected :String) -> GdUnitStringAssert:
	if __current().find(expected) != 0:
		return report_error(GdAssertMessages.error_starts_with(__current(), expected))
	return report_success()

func ends_with(expected :String) -> GdUnitStringAssert:
	var find = __current().length() - expected.length()
	if __current().rfind(expected) != find:
		return report_error(GdAssertMessages.error_ends_with(__current(), expected))
	return report_success()

func has_length(expected :int, comparator :int = Comparator.EQUAL) -> GdUnitStringAssert:
	match comparator:
		Comparator.EQUAL:
			if __current().length() != expected:
				return report_error(GdAssertMessages.error_has_length(__current(), expected, comparator))
		Comparator.LESS_THAN:
			if __current().length() >= expected:
				return report_error(GdAssertMessages.error_has_length(__current(), expected, comparator))
		Comparator.LESS_EQUAL:
			if __current().length() > expected:
				return report_error(GdAssertMessages.error_has_length(__current(), expected, comparator))
		Comparator.GREATER_THAN:
			if __current().length() <= expected:
				return report_error(GdAssertMessages.error_has_length(__current(), expected, comparator))
		Comparator.GREATER_EQUAL:
			if __current().length() < expected:
				return report_error(GdAssertMessages.error_has_length(__current(), expected, comparator))
		_:
			return report_error("Comparator '%d' not implemented!" % comparator)
	return report_success()

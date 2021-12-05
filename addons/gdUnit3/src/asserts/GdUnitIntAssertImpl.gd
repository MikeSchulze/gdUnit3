class_name GdUnitIntAssertImpl
extends GdUnitIntAssert

var _base: GdUnitAssert

func _init(caller :Object, current, expect_result :int = EXPECT_SUCCESS):
	_base = GdUnitAssertImpl.new(caller, current, expect_result)
	if not _base.__validate_value_type(current, TYPE_INT):
		report_error("GdUnitIntAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

# used from c# side to inject failure line number
func set_line_number(line :int) -> void:
	_base.set_line_number(line)

# used from c# side
func is_failed() -> bool:
	return _base.is_failed()

func __current() -> int:
	return _base.__current()

func report_success() -> GdUnitIntAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitIntAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitIntAssert:
	_base.has_failure_message(expected)
	return self

func starts_with_failure_message(expected: String) -> GdUnitIntAssert:
	_base.starts_with_failure_message(expected)
	return self

func override_failure_message(message :String) -> GdUnitIntAssert:
	_base.override_failure_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------
# Verifies that the current value is null.
func is_null() -> GdUnitIntAssert:
	_base.is_null()
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitIntAssert:
	_base.is_not_null()
	return self

# Verifies that the current value is equal to expected one.
func is_equal(expected :int) -> GdUnitIntAssert:
	_base.is_equal(expected)
	return self

# Verifies that the current value is not equal to expected one.
func is_not_equal(expected :int) -> GdUnitIntAssert:
	_base.is_not_equal(expected)
	return self

# Verifies that the current value is less than the given one.
func is_less(expected :int) -> GdUnitIntAssert:
	var current := __current()
	if current >= expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.LESS_THAN, current, expected))
	return report_success()

# Verifies that the current value is less than or equal the given one.
func is_less_equal(expected :int) -> GdUnitIntAssert:
	var current := __current()
	if current > expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.LESS_EQUAL, current, expected))
	return report_success()

# Verifies that the current value is greater than the given one.
func is_greater(expected :int) -> GdUnitIntAssert:
	var current := __current()
	if current <= expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_THAN, current, expected))
	return report_success()

# Verifies that the current value is greater than or equal the given one.
func is_greater_equal(expected :int) -> GdUnitIntAssert:
	var current := __current()
	if current < expected:
		return report_error(GdAssertMessages.error_is_value(Comparator.GREATER_EQUAL, current, expected))
	return report_success()

# Verifies that the current value is even.
func is_even() -> GdUnitIntAssert:
	var current := __current()
	if current % 2 != 0:
		return report_error(GdAssertMessages.error_is_even(current))
	return report_success()

# Verifies that the current value is odd.
func is_odd() -> GdUnitIntAssert:
	var current := __current()
	if current % 2 == 0:
		return report_error(GdAssertMessages.error_is_odd(current))
	return report_success()

# Verifies that the current value is negative.
func is_negative() -> GdUnitIntAssert:
	var current := __current()
	if current >= 0:
		return report_error(GdAssertMessages.error_is_negative(current))
	return report_success()

# Verifies that the current value is not negative.
func is_not_negative() -> GdUnitIntAssert:
	var current := __current()
	if current < 0:
		return report_error(GdAssertMessages.error_is_not_negative(current))
	return report_success()

# Verifies that the current value is equal to zero.
func is_zero() -> GdUnitIntAssert:
	var current := __current()
	if current != 0:
		return report_error(GdAssertMessages.error_is_zero(current))
	return report_success()

# Verifies that the current value is not equal to zero.
func is_not_zero() -> GdUnitIntAssert:
	var current := __current()
	if current == 0:
		return report_error(GdAssertMessages.error_is_not_zero())
	return report_success()

# Verifies that the current value is in the given set of values.
func is_in(expected :Array) -> GdUnitIntAssert:
	var current := __current()
	if not expected.has(current):
		return report_error(GdAssertMessages.error_is_in(current, expected))
	return report_success()

# Verifies that the current value is not in the given set of values.
func is_not_in(expected :Array) -> GdUnitIntAssert:
	var current := __current()
	if expected.has(current):
		return report_error(GdAssertMessages.error_is_not_in(current, expected))
	return report_success()

# Verifies that the current value is between the given boundaries (inclusive).
func is_between(from :int, to :int) -> GdUnitIntAssert:
	var current := __current()
	if current < from or current > to:
		return report_error(GdAssertMessages.error_is_value(Comparator.BETWEEN_EQUAL, current, from, to))
	return report_success()

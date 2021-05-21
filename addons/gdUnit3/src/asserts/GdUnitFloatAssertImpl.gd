class_name GdUnitFloatAssertImpl
extends GdUnitFloatAssert

var _base: GdUnitAssert

func _init(caller :Object, current, expect_result :int):
	_base = GdUnitAssertImpl.new(caller, current, expect_result)
	if typeof(current) != TYPE_REAL:
		report_error("GdUnitFloatAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __current() -> float:
	return _base._current

func report_success() -> GdUnitFloatAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitFloatAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_error_message(expected: String) -> GdUnitFloatAssert:
	_base.has_error_message(expected)
	return self

func starts_with_error_message(expected: String) -> GdUnitFloatAssert:
	_base.starts_with_error_message(expected)
	return self

func as_error_message(message :String) -> GdUnitFloatAssert:
	_base.as_error_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

# Verifies that the current value is equal to expected one.
func is_equal(expected :float) -> GdUnitFloatAssert:
	_base.is_equal(expected)
	return self

# Verifies that the current value is not equal to expected one.
func is_not_equal(expected :float) -> GdUnitFloatAssert:
	_base.is_not_equal(expected)
	return self

# Verifies that the current value is less than the given one.
func is_less(expected :float) -> GdUnitFloatAssert:
	var current := __current()
	if current >= expected:
		report_error(GdAssertMessages.error_is_value(current, expected, Comparator.LESS_THAN))
	return report_success()

# Verifies that the current value is less than or equal the given one.
func is_less_equal(expected :float) -> GdUnitFloatAssert:
	var current := __current()
	if current > expected:
		report_error(GdAssertMessages.error_is_value(current, expected, Comparator.LESS_EQUAL))
	return report_success()

# Verifies that the current value is greater than the given one.
func is_greater(expected :float) -> GdUnitFloatAssert:
	var current := __current()
	if current <= expected:
		return report_error(GdAssertMessages.error_is_value(current, expected, Comparator.GREATER_THAN))
	return report_success()

# Verifies that the current value is greater than or equal the given one.
func is_greater_equal(expected :float) -> GdUnitFloatAssert:
	var current := __current()
	if current < expected:
		return report_error(GdAssertMessages.error_is_value(current, expected, Comparator.GREATER_EQUAL))
	return report_success()

# Verifies that the current value is negative.
func is_negative() -> GdUnitFloatAssert:
	var current := __current()
	if current >= 0.0:
		return report_error(GdAssertMessages.error_is_negative(current))
	return report_success()

# Verifies that the current value is not negative.
func is_not_negative() -> GdUnitFloatAssert:
	var current := __current()
	if current < 0.0:
		return report_error(GdAssertMessages.error_is_not_negative(current))
	return report_success()

# Verifies that the current value is equal to zero.
func is_zero() -> GdUnitFloatAssert:
	var current := __current()
	if not is_equal_approx(0.00000000, current):
		return report_error(GdAssertMessages.error_is_zero(current))
	return report_success()

# Verifies that the current value is not equal to zero.
func is_not_zero() -> GdUnitFloatAssert:
	var current := __current()
	if is_equal_approx(0.00000000, current):
		return report_error(GdAssertMessages.error_is_not_zero())
	return report_success()

# Verifies that the current value is in the given set of values.
func is_in(expected :Array) -> GdUnitFloatAssert:
	var current := __current()
	if not expected.has(current):
		return report_error(GdAssertMessages.error_is_in(current, expected))
	return report_success()

# Verifies that the current value is not in the given set of values.
func is_not_in(expected :Array) -> GdUnitFloatAssert:
	var current := __current()
	if expected.has(current):
		return report_error(GdAssertMessages.error_is_not_in(current, expected))
	return report_success()

# Verifies that the current value is in range (from, to) inclusive from and to.
func is_in_range(from :float, to :float) -> GdUnitFloatAssert:
	var current := __current()
	if current < from or current > to:
		return report_error(GdAssertMessages.error_is_in_range(current, from, to))
	return report_success()


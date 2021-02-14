# An Assertion Tool to verify integer values
class_name GdUnitIntAssert
extends GdUnitAssert

# Verifies that the current value is equal to expected one.
func is_equal(expected :int) -> GdUnitIntAssert:
	return self

# Verifies that the current value is not equal to expected one.
func is_not_equal(expected :int) -> GdUnitIntAssert:
	return self

# Verifies that the current value is less than the given one.
func is_less(expected :int) -> GdUnitIntAssert:
	return self

# Verifies that the current value is less than or equal the given one.
func is_less_equal(expected :int) -> GdUnitIntAssert:
	return self

# Verifies that the current value is greater than the given one.
func is_greater(expected :int) -> GdUnitIntAssert:
	return self

# Verifies that the current value is greater than or equal the given one.
func is_greater_equal(expected :int) -> GdUnitIntAssert:
	return self

# Verifies that the current value is even.
func is_even() -> GdUnitIntAssert:
	return self

# Verifies that the current value is odd.
func is_odd() -> GdUnitIntAssert:
	return self

# Verifies that the current value is negative.
func is_negative() -> GdUnitIntAssert:
	return self

# Verifies that the current value is not negative.
func is_not_negative() -> GdUnitIntAssert:
	return self

# Verifies that the current value is equal to zero.
func is_zero() -> GdUnitIntAssert:
	return self
	
# Verifies that the current value is not equal to zero.
func is_not_zero() -> GdUnitIntAssert:
	return self

# Verifies that the current value is in the given set of values.
func is_in(expected :Array) -> GdUnitIntAssert:
	return self

# Verifies that the current value is not in the given set of values.
func is_not_in(expected :Array) -> GdUnitIntAssert:
	return self

# Verifies that the current value is in range (from, to) inclusive from and to.
func is_in_range(from :int, to :int) -> GdUnitIntAssert:
	return self


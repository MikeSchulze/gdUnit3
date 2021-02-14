# An Assertion Tool to verify array values
class_name GdUnitArrayAssert
extends GdUnitAssert


# Verifies that the current value is null.
func is_null() -> GdUnitArrayAssert:
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is equal to the given one.
func is_equal(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is equal to the given one, ignoring case considerations.
func is_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is not equal to the given one.
func is_not_equal(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is not equal to the given one, ignoring case considerations.
func is_not_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is empty, it has a size of 0.
func is_empty() -> GdUnitArrayAssert:
	return self

# Verifies that the current Array is not empty, it has a size of minimum 1.
func is_not_empty() -> GdUnitArrayAssert:
	return self

# Verifies that the current Array has a size of given value.
func has_size(expectd: int) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array contains the given values, in any order.
func contains(expected) -> GdUnitArrayAssert:
	return self

# Verifies that the current Array contains exactly only the given values and nothing else, in same order.
func contains_exactly(expected) -> GdUnitArrayAssert:
	return self

func extract(func_name: String) -> GdUnitArrayAssert:
	return self

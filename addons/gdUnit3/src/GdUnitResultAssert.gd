# An Assertion Tool to verify Results
class_name GdUnitResultAssert
extends GdUnitAssert

# Verifies that the current value is null.
func is_null() -> GdUnitResultAssert:
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitResultAssert:
	return self

# Verifies that the result is ends up with success
func is_success() -> GdUnitResultAssert:
	return self

# Verifies that the result is ends up with warning
func is_warning() -> GdUnitResultAssert:
	return self

# Verifies that the result is ends up with error
func is_error() -> GdUnitResultAssert:
	return self

# Verifies that the result contains the given message
func contains_message(expected :String) -> GdUnitResultAssert:
	return self

# Verifies that the result contains the given value
func is_value(expected) -> GdUnitResultAssert:
	return self

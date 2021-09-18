# An Assertion Tool to verify function callback values
class_name GdUnitFuncAssert
extends GdUnitAssert


# Verifies that the current value is null.
func is_null() -> GdUnitAssert:
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitAssert:
	return self

# Verifies that the current value is equal to the given one.
func is_equal(expected) -> GdUnitAssert:
	return self

# Verifies that the current value is not equal to the given one.
func is_not_equal(expected) -> GdUnitAssert:
	return self

# Verifies that the current value is true.
func is_true() -> GdUnitAssert:
	return self

# Verifies that the current value is false.
func is_false() -> GdUnitAssert:
	return self

func override_failure_message(message :String) -> GdUnitAssert:
	return self

# Sets the assert into a `wait until` mode to verifiy the current value has a expected value until a given timeout.
# If the timeout is happen an failure will be reported
# e.g. assert_func(instance, "is_state").wait_until(5000).is_equal(10)
# will verify the `is_state` is set to 10 until 5s 
func wait_until(timeout :int) -> GdUnitAssert:
	return self

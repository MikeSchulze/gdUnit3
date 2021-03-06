class_name GdUnitObjectAssertImpl
extends GdUnitObjectAssert


var _base :GdUnitAssert
var _memory_pool :int

func _init(current, memory_pool :int, expect_result :int):
	_memory_pool = memory_pool
	_base = GdUnitAssertImpl.new(current, expect_result)
	if current != null and typeof(current) != TYPE_OBJECT:
		report_error("GdUnitObjectAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __current() -> Object:
	return _base._current as Object

func report_success() -> GdUnitObjectAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitObjectAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_error_message(expected: String) -> GdUnitObjectAssert:
	_base.has_error_message(expected)
	return self
	
func starts_with_error_message(expected: String) -> GdUnitObjectAssert:
	_base.starts_with_error_message(expected)
	return self

func as_error_message(message :String) -> GdUnitObjectAssert:
	_base.as_error_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

# Verifies that the current value is equal to expected one.
func is_equal(expected) -> GdUnitObjectAssert:
	_base.is_equal(expected)
	return self

# Verifies that the current value is not equal to expected one.
func is_not_equal(expected) -> GdUnitObjectAssert:
	_base.is_not_equal(expected)
	return self

# Verifies that the current value is null.
func is_null() -> GdUnitObjectAssert:
	_base.is_null()
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitObjectAssert:
	_base.is_not_null()
	return self

# Verifies that the current value is the same as the given one.
func is_same(expected) -> GdUnitObjectAssert:
	if not GdObjects.is_same(_base._current, expected):
		report_error(GdAssertMessages.error_is_same(_base._current, expected))
		return self
	report_success()
	return self

# Verifies that the current value is not the same as the given one.
func is_not_same(expected) -> GdUnitObjectAssert:
	var current_ = __current()
	if GdObjects.is_same(current_, expected):
		report_error(GdAssertMessages.error_not_same(current_, expected))
		return self
	report_success()
	return self

# Verifies that the current value is an instance of the given type.
func is_instanceof(type) -> GdUnitObjectAssert:
	var current_ := __current()
	if not GdObjects.is_instanceof(current_, type):
		var result_expected: = GdObjects.extract_class_name(type)
		var result_current: = GdObjects.extract_class_name(current_)
		report_error(GdAssertMessages.error_is_instanceof(result_current, result_expected))
		return self
	report_success()
	return self

# Verifies that the current value is not an instance of the given type.
func is_not_instanceof(type) -> GdUnitObjectAssert:
	var current_ := __current()
	if GdObjects.is_instanceof(current_, type):
		var result: = GdObjects.extract_class_name(type)
		if result.is_success():
			report_error("Expected not be a instance of <%s>" % result.value())
		else:
			push_error("Internal ERROR: %s" % result.error_message())
		return self
	report_success()
	return self

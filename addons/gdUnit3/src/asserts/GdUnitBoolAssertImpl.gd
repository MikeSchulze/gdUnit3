class_name GdUnitBoolAssertImpl
extends GdUnitBoolAssert

var _base: GdUnitAssert

func _init(current, expect_result: int):
	_base = GdUnitAssertImpl.new(current, expect_result)
	if typeof(current) != TYPE_BOOL:
		report_error("GdUnitBoolAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __current() -> bool:
	return _base._current as bool

func report_success() -> GdUnitBoolAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitBoolAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_error_message(expected: String) -> GdUnitBoolAssert:
	_base.has_error_message(expected)
	return self

func starts_with_error_message(expected: String) -> GdUnitBoolAssert:
	_base.starts_with_error_message(expected)
	return self

func as_error_message(message :String) -> GdUnitBoolAssert:
	_base.as_error_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

func is_equal(expected) -> GdUnitBoolAssert:
	_base.is_equal(expected)
	return self

func is_not_equal(expected) -> GdUnitBoolAssert:
	_base.is_not_equal(expected)
	return self

func is_true() -> GdUnitBoolAssert:
	if __current() != true:
		return report_error(GdAssertMessages.error_is_true())
	return report_success()
	
func is_false() -> GdUnitBoolAssert:
	if __current() == true:
		return report_error(GdAssertMessages.error_is_false())
	return report_success()

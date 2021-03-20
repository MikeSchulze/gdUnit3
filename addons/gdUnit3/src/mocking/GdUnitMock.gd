class_name GdUnitMock
extends Reference

# do call the real implementation
const CALL_REAL_FUNC = "CALL_REAL_FUNC"
# do return a default value for primitive types or null 
const RETURN_DEFAULTS = "RETURN_DEFAULTS"
# do return a default value for primitive types and a fully mocked value for Object types
# builds full deep mocked object
const RETURN_DEEP_STUB = "RETURN_DEEP_STUB"

var _value
	
func _init(value):
	_value = value

func on(obj :Object):
	if not _is_mock_or_spy( obj, "__do_return"):
		return obj
	return obj.__do_return(_value)

static func verify(obj :Object, times):
	if not _is_mock_or_spy( obj, "__verify"):
		return obj
	return obj.__do_verify(times)

static func verify_no_interactions(obj :Object) -> Object:
	if not _is_mock_or_spy( obj, "__verify"):
		return obj
	obj.__verify_no_interactions()
	return obj

static func verify_no_more_interactions(obj :Object, expect_result :int) -> GdUnitAssert:
	var gd_assert := GdUnitAssertImpl.new("", expect_result)
	if not _is_mock_or_spy( obj, "__verify_no_more_interactions"):
		return gd_assert
	var summary :Dictionary = obj.__verify_no_more_interactions()
	if summary.empty():
		return gd_assert
	gd_assert.report_error(GdAssertMessages.error_no_more_interactions(summary))
	return gd_assert

static func reset(obj :Object) -> Object:
	if not _is_mock_or_spy( obj, "__reset"):
		return obj
	obj.__reset()
	return obj


static func _is_mock_or_spy(obj :Object, func_sig :String) -> bool:
	if obj is GDScript and not obj.get_script().has_script_method(func_sig):
		push_error("Error: You try to use a non mock or spy!")
		return false
	return true

class_name GdUnitFileAssertImpl
extends GdUnitFileAssert

var _base: GdUnitAssert
var _caller :Object

func _init(caller :Object, current, expect_result: int):
	_caller = caller
	_base = GdUnitAssertImpl.new(caller, current, expect_result)
	if typeof(current) != TYPE_STRING:
		report_error("GdUnitFileAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func report_success() -> GdUnitFileAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitFileAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_error_message(expected: String) -> GdUnitFileAssert:
	_base.has_error_message(expected)
	return self

func starts_with_error_message(expected: String) -> GdUnitFileAssert:
	_base.starts_with_error_message(expected)
	return self

func as_error_message(message :String) -> GdUnitFileAssert:
	_base.as_error_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

func is_equal(expected) -> GdUnitFileAssert:
	_base.is_equal(expected)
	return self

func is_not_equal(expected) -> GdUnitFileAssert:
	_base.is_not_equal(expected)
	return self

func is_file() -> GdUnitFileAssert:
	var file := File.new()
	var ret = file.open(_base._current, File.READ)
	if ret != OK:
		return report_error("Is not a file '%s', error code %s" % [_base._current, ret])
	return report_success()

func exists() -> GdUnitFileAssert:
	var file := File.new()
	if not file.file_exists(_base._current):
		return report_error("The file '%s' not exists" %_base._current)
	return report_success()

func is_script() -> GdUnitFileAssert:
	var file := File.new()
	var ret = file.open(_base._current, File.READ)
	if ret != OK:
		return report_error("Can't acces the file '%s'! Error code %s" % [_base._current, ret])
	
	var script = load(_base._current)
	if not script is GDScript:
		return report_error("The file '%s' is not a GdScript" % _base._current)
	return report_success()

func contains_exactly(expected_rows :Array) -> GdUnitFileAssert:
	var file := File.new()
	var ret = file.open(_base._current, File.READ)
	if ret != OK:
		return report_error("Can't acces the file '%s'! Error code %s" % [_base._current, ret])
	
	var script = load(_base._current)
	if script is GDScript:
		var instance = script.new()
		var source_code = GdScriptParser.to_unix_format(instance.get_script().source_code)
		GdUnitTools.free_instance(instance)
		var rows := Array(source_code.split("\n"))
		GdUnitArrayAssertImpl.new(_caller, rows, GdUnitAssert.EXPECT_SUCCESS).contains_exactly(expected_rows)
	return self

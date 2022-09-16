class_name GdUnitTestCaseDto
extends GdUnitResourceDto

var _line_number :int = -1
var _input_value_set :Array = []

func serialize(test_case) -> Dictionary:
	var serialized := .serialize(test_case)
	if test_case.has_method("line_number"):
		serialized["line_number"] = test_case.line_number()
	else:
		serialized["line_number"] = test_case.get("LineNumber")
	if test_case.has_method("input_value_set"):
		serialized["input_value_set"] = test_case.input_value_set()
	return serialized

func deserialize(data :Dictionary) -> GdUnitResourceDto:
	.deserialize(data)
	_line_number = data.get("line_number", -1)
	_input_value_set = data.get("input_value_set", [])
	return self

func line_number() -> int:
	return _line_number

func input_value_set() -> Array:
	return _input_value_set

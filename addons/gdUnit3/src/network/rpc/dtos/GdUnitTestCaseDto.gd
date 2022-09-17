class_name GdUnitTestCaseDto
extends GdUnitResourceDto

var _line_number :int = -1
var _test_parameters :Array = []

func serialize(test_case) -> Dictionary:
	var serialized := .serialize(test_case)
	if test_case.has_method("line_number"):
		serialized["line_number"] = test_case.line_number()
	else:
		serialized["line_number"] = test_case.get("LineNumber")
	if test_case.has_method("test_parameters"):
		serialized["test_parameters"] = test_case.test_parameters()
	return serialized

func deserialize(data :Dictionary) -> GdUnitResourceDto:
	.deserialize(data)
	_line_number = data.get("line_number", -1)
	_test_parameters = data.get("test_parameters", [])
	return self

func line_number() -> int:
	return _line_number

func test_parameters() -> Array:
	return _test_parameters

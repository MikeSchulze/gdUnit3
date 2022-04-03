class_name GdUnitTestCaseDto
extends GdUnitResourceDto

var _line_number :int = -1

func serialize(test_case) -> Dictionary:
	var serialized := .serialize(test_case)
	if test_case.has_method("line_number"):
		serialized["line_number"] = test_case.line_number()
	else:
		serialized["line_number"] = test_case.get_meta("LineNumber")
	return serialized

func deserialize(data :Dictionary) -> GdUnitResourceDto:
	.deserialize(data)
	_line_number = data.get("line_number", -1 )
	return self

func line_number() -> int:
	return _line_number

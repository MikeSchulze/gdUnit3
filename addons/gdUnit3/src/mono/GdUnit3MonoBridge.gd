extends Reference
class_name GdUnit3MonoBridge

const _instance : = []

static func instance() :
	if not _instance.empty():
		return _instance[0]
	var instance =  load("res://addons/gdUnit3/src/mono/GdUnit3MonoBridge.cs").new()
	_instance[0] = instance
	return _instance

static func create_test_suite(source_path :String, line_number :int, test_suite_path :String) -> Result:
	if not GdUnitTools.is_mono_supported():
		return  Result.error("Can't create test suite. No c# support found.")
	var result := instance().CreateTestSuite(source_path, line_number, test_suite_path) as Dictionary
	if result.has("error"):
		return Result.error(result.get("error"))
	return  Result.success(result)

static func is_test_suite(script :Script) -> bool:
	if not GdUnitTools.is_mono_supported():
		return false
	if script.resource_path.empty():
		push_error("Can't create test suite. Missing resource path at %s." % script)
		return  false
	return instance().IsTestSuite(script.resource_path)

static func parse_test_suite(source_path :String) -> Node:
	if not GdUnitTools.is_mono_supported():
		push_error("Can't create test suite. No c# support found.")
		return null
	return instance().ParseTestSuite(source_path)

static func create_executor(listener :Node) -> Node:
	if not GdUnitTools.is_mono_supported():
		return null
	return instance().Executor(listener)

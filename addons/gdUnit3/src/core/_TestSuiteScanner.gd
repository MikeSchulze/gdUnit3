class_name _TestSuiteScanner
extends Node


var _script_parser := GdScriptParser.new()
var _extends_test_suite_classes:Array = Array()


func scan(resource_path:String) -> Array:
	# scan and cache extends GdUnitTestSuite classes
	_extends_test_suite_classes.append("GdUnitTestSuite")
	if ProjectSettings.has_setting("_global_script_classes"):
		var script_classes:Array = ProjectSettings.get_setting("_global_script_classes") as Array
		for element in script_classes:
			var script_meta = element as Dictionary
			if script_meta["base"] == "GdUnitTestSuite":
				_extends_test_suite_classes.append(script_meta["class"] )

	var base_dir := Directory.new()
	# if single testsuite requested
	if base_dir.file_exists(resource_path):
		if resource_path.ends_with(".gd") and _is_test_suite(resource_path):
			return [_parse_test_suite(resource_path)]

	if base_dir.open(resource_path) != OK:
			prints("Given directory or file does not exists:", resource_path)
			return []
	return _scan_test_suites(base_dir, [])

func _scan_test_suites(dir:Directory, collected_suites:Array) -> Array:
	prints("Scanning for test suites in:", dir.get_current_dir())
	dir.list_dir_begin(true, true)
	var file_name := dir.get_next()
	while file_name != "":
		var current = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			var sub_dir := Directory.new()
			if sub_dir.open(current) == OK:
				_scan_test_suites(sub_dir, collected_suites)
		else:
			if _is_test_suite(current):
				collected_suites.append(_parse_test_suite(current))

		file_name = dir.get_next()
	return collected_suites

func _is_test_suite(file_name:String) -> bool:
	# only scan on gd scrip files
	if not file_name.ends_with(".gd"):
		return false
	# exclude non test directories
	if file_name.find("/test") == -1:
		return false

	var file := File.new()
	file.open(file_name, File.READ)
	var found:bool = false
	while not file.eof_reached():
		var row := file.get_line().strip_edges()
		# ignore comments and empty lines
		if row.begins_with("#") || row.length() == 0:
			continue
		# if extends from GdUnitTestSuite
		var clazz_name := row.trim_prefix("extends").strip_edges()
		if _extends_test_suite_classes.has(clazz_name):
			found = true
			break
	file.close()
	return found

func _parse_test_suite(resource_path:String) -> GdUnitTestSuite:
	var test_suite := load(resource_path).new() as GdUnitTestSuite
	test_suite.set_name(parse_test_suite_name(resource_path))
	# find all test cases as array of names
	var test_case_names := _extract_test_case_names(test_suite)
	# add test cases to test suite and parse test case line nummber
	_parse_and_add_test_cases(test_suite, resource_path, test_case_names)
	# not all test case parsed?
	# we have to scan the base class to
	if not test_case_names.empty():
		var path = test_suite.get_script().get_base_script().resource_path
		_parse_and_add_test_cases(test_suite, path, test_case_names)
	return test_suite

func _extract_test_case_names(test_suite :GdUnitTestSuite) -> PoolStringArray:
	var names := PoolStringArray()
	for method in test_suite.get_script().get_script_method_list():
		#prints(method["flags"], method["name"] )
		var flags :int = method["flags"]
		var funcName :String = method["name"]
		if funcName.begins_with("test"):
			names.append(funcName)
	return names

static func parse_test_suite_name(resource_path :String) -> String:
	var start := resource_path.find_last("/")
	var end := resource_path.find_last(".gd")
	return resource_path.substr(start, end-start)

func _parse_and_add_test_cases(test_suite :GdUnitTestSuite, resource_path :String, test_case_names :PoolStringArray):
	var test_cases_to_find = Array(test_case_names)
	var file := File.new()
	file.open(resource_path, File.READ)
	var line_number:int = 0
	file.seek(0)
	
	while not file.eof_reached():
		var row := GdScriptParser.clean_up_row(file.get_line())
		line_number += 1
		
		# ignore comments and empty lines and not test functions
		if row.begins_with("#") || row.length() == 0 || row.find("functest") == -1:
			continue
		
		# extract current test case name from the row
		var func_name := _script_parser.parse_func_name(row)
		if test_cases_to_find.has(func_name):
			test_cases_to_find.erase(func_name)
			# grap test arguments
			var timeout = _script_parser.parse_argument(row, _TestCase.ARGUMENT_TIMEOUT, _TestCase.DEFAULT_TIMEOUT)
			var iterations = _script_parser.parse_argument(row, Fuzzer.ARGUMENT_ITERATIONS, Fuzzer.ITERATION_DEFAULT_COUNT)
			var seed_value = _script_parser.parse_argument(row, Fuzzer.ARGUMENT_SEED, -1)
			var fuzzers := _script_parser.parse_fuzzers(row)
			test_suite.add_child(_TestCase.new().configure(func_name, line_number, resource_path, timeout, fuzzers, iterations, seed_value))
	
	file.close()

static func build_test_suite_path(resource_path :String) -> String:
	var file_extension := resource_path.get_extension()
	var file_name = resource_path.get_file().replace("." + file_extension, "")
	var test_suite_path :String
	
	# is user tmp
	if resource_path.begins_with("user://tmp"):
		return resource_path.replace("user://tmp", "user://tmp/test").replace(file_name, "%sTest" % file_name)
	
	# at first look up is the script under a "src" folder located
	var src_folder = resource_path.find("/src/")
	if src_folder != -1:
		test_suite_path = resource_path.replace("/src/", "/test/")
	else:
		var paths = resource_path.split("/", false)
		# is a plugin script?
		if paths[1] == "addons":
			test_suite_path = "%s//addons/%s/%s" % [paths[0], paths[2], "test"]
			# rebuild plugin path
			for index in range(3, paths.size()):
				test_suite_path += "/" + paths[index]
		else:
			test_suite_path = paths[0] + "//" + "test"
			for index in range(1, paths.size()):
				test_suite_path += "/" + paths[index]
	return test_suite_path.replace(file_name, "%sTest" % file_name)

static func save_test_suite(path :String, source_path :String) -> Result:
	# create directory if not exists
	if not Directory.new().dir_exists(path.get_base_dir()):
		var error := Directory.new().make_dir_recursive(path.get_base_dir())
		if error != OK:
			return Result.error("Can't create directoy  at: %s. Error code %s" % [path.get_base_dir(), error])

	var file_extension := path.get_extension()
	var clazz_name = path.get_file().replace("." + file_extension, "")
	var script := GDScript.new()
	script.source_code +=\
"""# GdUnit generated TestSuite
class_name ${class_name}
extends GdUnitTestSuite

# TestSuite generated from
const __source = '${source_path}'
""".replace("${class_name}", clazz_name)\
	.replace("${source_path}", source_path)
	var error := ResourceSaver.save(path, script)
	if error != OK:
		return Result.error("Can't create test suite at: %s. Error code %s" % [path, error])
	return Result.success(path)

static func add_test_case(resource_path :String, func_name :String)  -> Result:
	var file := File.new()
	var error: = file.open(resource_path, File.READ)
	if error != OK:
		return Result.error("Can't access test suite : %s. Error code %s" % [resource_path, error])
	var line_number = 0
	while not file.eof_reached():
		file.get_line()
		line_number += 1
	file.close()
	line_number += 1

	var script := load(resource_path) as GDScript
	script.source_code +=\
"""
func test_${func_name}() -> void:
	# remove this line and complete your test
	assert_not_yet_implemented()
""".replace("${func_name}", func_name)
	error = ResourceSaver.save(resource_path, script)
	if error != OK:
		return Result.error("Can't add test case at: %s to '%s'. Error code %s" % [func_name, resource_path, error])
	return Result.success({ "path" : resource_path, "line" : line_number})

static func test_suite_exists(path :String) -> bool:
	return File.new().file_exists(path)

static func test_case_exists(resource_path :String, func_name :String) -> bool:
	var test_suite := ResourceLoader.load(resource_path).new() as GdUnitTestSuite
	var script := test_suite.get_script() as GDScript
	test_suite.free()
	for f in script.get_script_method_list():
		if f["name"] == "test_" + func_name:
			return true
	return false

static func create_test_case(source_path :String, func_name :String) -> Result:
	var path := build_test_suite_path(source_path)
	if not test_suite_exists(path):
		var result := save_test_suite(path, source_path)
		if result.is_error():
			return result
	if test_case_exists(path, func_name):
		return Result.warn("Test Case 'test_%s' already exists in '%s'" % [func_name, path], path)

	return add_test_case(path, func_name)

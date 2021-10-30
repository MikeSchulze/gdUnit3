class_name _TestSuiteScanner
extends Node


var _script_parser := GdScriptParser.new()
var _extends_test_suite_classes := Array()


func scan_testsuite_classes() -> void:
	# scan and cache extends GdUnitTestSuite by class name an resource paths
	_extends_test_suite_classes.append("GdUnitTestSuite")
	if ProjectSettings.has_setting("_global_script_classes"):
		var script_classes:Array = ProjectSettings.get_setting("_global_script_classes") as Array
		for element in script_classes:
			var script_meta = element as Dictionary
			if script_meta["base"] == "GdUnitTestSuite":
				_extends_test_suite_classes.append(script_meta["class"])

func scan(resource_path :String) -> Array:
	var base_dir := Directory.new()
	# if single testsuite requested
	if base_dir.file_exists(resource_path):
		if resource_path.ends_with(".gd") and _is_test_suite(resource_path):
			return [_parse_test_suite(resource_path)]

	if base_dir.open(resource_path) != OK:
			prints("Given directory or file does not exists:", resource_path)
			return []
	return _scan_test_suites(base_dir, [])

func _scan_test_suites(dir :Directory, collected_suites :Array) -> Array:
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

func _is_test_suite(file_name :String) -> bool:
	# only scan on gd scrip files
	if not file_name.ends_with(".gd"):
		return false
	# exclude non test directories
	if file_name.find("/test") == -1:
		return false
	return GdObjects.is_testsuite(ResourceLoader.load(file_name))

func _parse_test_suite(resource_path :String) -> GdUnitTestSuite:
	var test_suite := load(resource_path).new() as GdUnitTestSuite
	test_suite.set_name(parse_test_suite_name(resource_path))
	# find all test cases as array of names
	var test_case_names := _extract_test_case_names(test_suite)
	# add test cases to test suite and parse test case line nummber
	_parse_and_add_test_cases(test_suite, resource_path, test_case_names)
	# not all test case parsed?
	# we have to scan the base class to
	if not test_case_names.empty():
		var base_script :GDScript = test_suite.get_script().get_base_script()
		while base_script is GDScript:
			_parse_and_add_test_cases(test_suite, base_script.resource_path, test_case_names)
			base_script = base_script.get_base_script()
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

# converts given file name by configured naming convention
static func _to_naming_convention(file_name :String) -> String:
	var nc :int = GdUnitSettings.get_setting(GdUnitSettings.TEST_SITE_NAMING_CONVENTION, 0)
	match nc:
		GdUnitSettings.NAMING_CONVENTIONS.AUTO_DETECT:
			if GdObjects.is_snake_case(file_name):
				return GdObjects.to_snake_case(file_name + "Test")
			return GdObjects.to_pascal_case(file_name + "Test")
		GdUnitSettings.NAMING_CONVENTIONS.SNAKE_CASE:
			return GdObjects.to_snake_case(file_name + "Test")
		GdUnitSettings.NAMING_CONVENTIONS.PASCAL_CASE:
			return GdObjects.to_pascal_case(file_name + "Test")
	push_error("Unexpected case")
	return "-<Unexpected>-"

static func resolve_test_suite_path(source_script_path :String, test_root_folder :String = "test") -> String:
	var file_extension := source_script_path.get_extension()
	var file_name = source_script_path.get_basename().get_file()
	var suite_name := _to_naming_convention(file_name)
	if test_root_folder.empty():
		return source_script_path.replace(file_name, suite_name)
	
	# is user tmp
	if source_script_path.begins_with("user://tmp"):
		return source_script_path.replace("user://tmp", "user://tmp/" + test_root_folder).replace(file_name, suite_name)
	
	# at first look up is the script under a "src" folder located
	var test_suite_path :String
	var src_folder = source_script_path.find("/src/")
	if src_folder != -1:
		test_suite_path = source_script_path.replace("/src/", "/"+test_root_folder+"/")
	else:
		var paths = source_script_path.split("/", false)
		# is a plugin script?
		if paths[1] == "addons":
			test_suite_path = "%s//addons/%s/%s" % [paths[0], paths[2], test_root_folder]
			# rebuild plugin path
			for index in range(3, paths.size()):
				test_suite_path += "/" + paths[index]
		else:
			test_suite_path = paths[0] + "//" + test_root_folder
			for index in range(1, paths.size()):
				test_suite_path += "/" + paths[index]
	return test_suite_path.replace(file_name, suite_name)

static func create_test_suite(test_suite_path :String, source_path :String) -> Result:
	# create directory if not exists
	if not Directory.new().dir_exists(test_suite_path.get_base_dir()):
		var error := Directory.new().make_dir_recursive(test_suite_path.get_base_dir())
		if error != OK:
			return Result.error("Can't create directoy  at: %s. Error code %s" % [test_suite_path.get_base_dir(), error])
	var file_extension := test_suite_path.get_extension()
	var script := GDScript.new()
	script.source_code = GdUnitTestSuiteTemplate.build_template(source_path)
	var error := ResourceSaver.save(test_suite_path, script)
	if error != OK:
		return Result.error("Can't create test suite at: %s. Error code %s" % [test_suite_path, error])
	return Result.success(test_suite_path)

static func get_test_case_line_number(resource_path :String, func_name :String) -> int:
	var file := File.new()
	file.open(resource_path, File.READ)
	var script_parser := GdScriptParser.new()
	var line_number = 0
	while not file.eof_reached():
		var row := GdScriptParser.clean_up_row(file.get_line())
		line_number += 1
		# ignore comments and empty lines and not test functions
		if row.begins_with("#") || row.length() == 0 || row.find("functest") == -1:
			continue
		# abort if test case name found
		if script_parser.parse_func_name(row) == "test_" + func_name:
			file.close()
			return line_number
	file.close()
	return -1

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

static func test_suite_exists(test_suite_path :String) -> bool:
	return File.new().file_exists(test_suite_path)

static func test_case_exists(test_suite_path :String, func_name :String) -> bool:
	if not test_suite_exists(test_suite_path):
		return false
	var script := ResourceLoader.load(test_suite_path) as GDScript
	for f in script.get_script_method_list():
		if f["name"] == "test_" + func_name:
			return true
	return false

static func create_test_case(test_suite_path :String, func_name :String, source_script_path :String) -> Result:
	if test_case_exists(test_suite_path, func_name):
		var line_number := get_test_case_line_number(test_suite_path, func_name)
		return Result.success({ "path" : test_suite_path, "line" : line_number})
	
	if not test_suite_exists(test_suite_path):
		var result := create_test_suite(test_suite_path, source_script_path)
		if result.is_error():
			return result
	return add_test_case(test_suite_path, func_name)

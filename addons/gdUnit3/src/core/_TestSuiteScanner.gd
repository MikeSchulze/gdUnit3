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
	scan_testsuite_classes()
	var base_dir := Directory.new()
	# if single testsuite requested
	if base_dir.file_exists(resource_path):
		var test_suite := _parse_is_test_suite(resource_path)
		if test_suite:
			return [test_suite]

	if base_dir.open(resource_path) != OK:
			prints("Given directory or file does not exists:", resource_path)
			return []
	return _scan_test_suites(base_dir, [])

func _scan_test_suites(dir :Directory, collected_suites :Array) -> Array:
	prints("Scanning for test suites in:", dir.get_current_dir())
	dir.list_dir_begin(true, true)
	var file_name := dir.get_next()
	while file_name != "":
		var resource_path = _file(dir, file_name)
		if dir.current_is_dir():
			var sub_dir := Directory.new()
			if sub_dir.open(resource_path) == OK:
				_scan_test_suites(sub_dir, collected_suites)
		else:
			var test_suite := _parse_is_test_suite(resource_path)
			if test_suite:
				collected_suites.append(test_suite)
		file_name = dir.get_next()
	return collected_suites

static func _file(dir :Directory, file_name :String) -> String:
	var current_dir := dir.get_current_dir()
	if current_dir.ends_with("/"):
		return current_dir + file_name
	return current_dir + "/" + file_name

func _parse_is_test_suite(resource_path :String) -> Node:
	if not _is_script_format_supported(resource_path):
		return null
	if GdUnit3MonoAPI.is_test_suite(resource_path):
		return GdUnit3MonoAPI.parse_test_suite(resource_path)
	var script :Script = ResourceLoader.load(resource_path)
	if not GdObjects.is_test_suite(script):
		return null
	if GdObjects.is_gd_script(script):
		return _parse_test_suite(script)
	return null

static func _is_script_format_supported(resource_path :String) -> bool:
	var ext := resource_path.get_extension()
	if ext == "gd":
		return true
	return GdUnit3MonoAPI.is_csharp_file(resource_path)

func _parse_test_suite(script :GDScript) -> GdUnitTestSuite:
	var test_suite = script.new()
	test_suite.set_name(parse_test_suite_name(script))
	# find all test cases as array of names
	var test_case_names := _extract_test_case_names(script)
	# add test cases to test suite and parse test case line nummber
	_parse_and_add_test_cases(test_suite, script, test_case_names)
	# not all test case parsed?
	# we have to scan the base class to
	if not test_case_names.empty():
		var base_script :GDScript = test_suite.get_script().get_base_script()
		while base_script is GDScript:
			# do not parse testsuite itself
			if base_script.resource_path.find("GdUnitTestSuite") == -1:
				_parse_and_add_test_cases(test_suite, base_script, test_case_names)
			base_script = base_script.get_base_script()
	return test_suite

func _extract_test_case_names(script :GDScript) -> PoolStringArray:
	var names := PoolStringArray()
	for method in script.get_script_method_list():
		#prints(method["flags"], method["name"] )
		var flags :int = method["flags"]
		var funcName :String = method["name"]
		if funcName.begins_with("test"):
			names.append(funcName)
	return names

static func parse_test_suite_name(script :Script) -> String:
	return script.resource_path.get_file().replace(".gd", "")

func _parse_and_add_test_cases(test_suite, script :GDScript, test_case_names :PoolStringArray):
	var test_cases_to_find = Array(test_case_names)
	var source := _script_parser.load_source_code(script, [script.resource_path])
	var functions = _script_parser.parse_functions(source, "", [script.resource_path], test_case_names)
	for function in functions:
		var fd :GdFunctionDescriptor = function
		if test_cases_to_find.has(fd.name()):
			var timeout := _TestCase.DEFAULT_TIMEOUT
			var iterations := Fuzzer.ITERATION_DEFAULT_COUNT
			var seed_value := -1
			var fuzzers := PoolStringArray()
			for arg in fd.args():
				var fa := arg as GdFunctionArgument
				if fa.name() == _TestCase.ARGUMENT_TIMEOUT and fa.default() != null:
					timeout = int(fa.default())
				if fa.name() == Fuzzer.ARGUMENT_ITERATIONS and fa.default() != null:
					iterations = int(fa.default())
				if fa.name() == Fuzzer.ARGUMENT_SEED and fa.default() != null:
					seed_value = int(fa.default())
				# is test using fuzzers?
				if fa.type() == "Fuzzer":
					fuzzers.append(fa.name() + ":=" + fa.default())
			# create new test
			var test := _TestCase.new().configure(fd.name(), fd.line_number(), script.resource_path, timeout, fuzzers, iterations, seed_value)
			test_suite.add_child(test)
			# is parameterized test?
			if fd.is_parameterized():
				var test_paramaters := GdTestParameterSet.extract_test_parameters(test_suite.get_script(), fd)
				var error := GdTestParameterSet.validate(fd.args(), test_paramaters)
				if not error.empty():
					test.skip(true, error)
				test.set_test_parameters(test_paramaters)

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
	if file.open(resource_path, File.READ) == OK:
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

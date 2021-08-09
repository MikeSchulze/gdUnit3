class_name GdUnitTools
extends Resource

const GDUNIT_TEMP := "user://tmp"

enum {
	ERRORS,
	METHOD_FLAGS
}

const ENGINE_ENUM_MAPPINGS = { ERRORS: null, METHOD_FLAGS: null}

static func error_mapping() -> Dictionary:
	return {
	FAILED: "Generic error.",
	ERR_UNAVAILABLE: "Unavailable error.",
	ERR_UNCONFIGURED: "Unconfigured error.",
	ERR_UNAUTHORIZED: "Unauthorized error.",
	ERR_PARAMETER_RANGE_ERROR: "Parameter range error.",
	ERR_OUT_OF_MEMORY: "Out of memory (OOM) error.",
	ERR_FILE_NOT_FOUND: "File: Not found error.",
	ERR_FILE_BAD_DRIVE: "File: Bad drive error.",
	ERR_FILE_BAD_PATH: "File: Bad path error.",
	ERR_FILE_NO_PERMISSION: "File: No permission error.",
	ERR_FILE_ALREADY_IN_USE: "File: Already in use error.",
	ERR_FILE_CANT_OPEN: "File: Can't open error.",
	ERR_FILE_CANT_WRITE: "File: Can't write error.",
	ERR_FILE_CANT_READ: "File: Can't read error.",
	ERR_FILE_UNRECOGNIZED: "File: Unrecognized error.",
	ERR_FILE_CORRUPT: "File: Corrupt error.",
	ERR_FILE_MISSING_DEPENDENCIES: "File: Missing dependencies error.",
	ERR_FILE_EOF: "File: End of file (EOF) error.",
	ERR_CANT_OPEN: "Can't open error.",
	ERR_CANT_CREATE: "Can't create error.",
	ERR_QUERY_FAILED: "Query failed error.",
	ERR_ALREADY_IN_USE: "Already in use error.",
	ERR_LOCKED: "Locked error.",
	ERR_TIMEOUT: "Timeout error.",
	ERR_CANT_CONNECT: "Can't connect error.",
	ERR_CANT_RESOLVE: "Can't resolve error.",
	ERR_CONNECTION_ERROR: "Connection error.",
	ERR_CANT_ACQUIRE_RESOURCE: "Can't acquire resource error.",
	ERR_CANT_FORK: "Can't fork process error.",
	ERR_INVALID_DATA: "Invalid data error.",
	ERR_INVALID_PARAMETER: "Invalid parameter error.",
	ERR_ALREADY_EXISTS: "Already exists error.",
	ERR_DOES_NOT_EXIST: "Does not exist error.",
	ERR_DATABASE_CANT_READ: "Database: Read error.",
	ERR_DATABASE_CANT_WRITE: "Database: Write error.",
	ERR_COMPILATION_FAILED: "Compilation failed error.",
	ERR_METHOD_NOT_FOUND: "Method not found error.",
	ERR_LINK_FAILED: "Linking failed error.",
	ERR_SCRIPT_FAILED: "Script failed error.",
	ERR_CYCLIC_LINK: "Cycling link (import cycle) error.",
	ERR_INVALID_DECLARATION: "Invalid declaration error.",
	ERR_DUPLICATE_SYMBOL: "Duplicate symbol error.",
	ERR_PARSE_ERROR: "Parse error.",
	ERR_BUSY: "Busy error.",
	ERR_SKIP: "Skip error.",
	ERR_HELP: "Help error.",
	ERR_BUG: "Bug error.",
	ERR_PRINTER_ON_FIRE: "Printer on fire error. (This is an easter egg, no engine methods return this error code.)"
}

enum {
	MEMORY_POOL_TESTSUITE,
	MEMORY_POOL_TESTCASE,
	MEMORY_POOL_TESTRUN,
}

const _objects_to_delete := {
	MEMORY_POOL_TESTSUITE: Array(),
	MEMORY_POOL_TESTCASE: Array(),
	MEMORY_POOL_TESTRUN: Array(),
}

const _files_to_close :Array = []

static func temp_dir() -> String:
	var dir := Directory.new()
	if not dir.dir_exists(GDUNIT_TEMP):
		dir.make_dir_recursive(GDUNIT_TEMP)
	return GDUNIT_TEMP

static func create_temp_dir(folder_name :String) -> String:
	var new_folder = temp_dir() + "/" + folder_name
	var dir := Directory.new()
	if not dir.dir_exists(new_folder):
		dir.make_dir_recursive(new_folder)
	return new_folder

static func clear_tmp():
	delete_directory(GDUNIT_TEMP)
	
# Creates a new file under 
static func create_temp_file(relative_path :String, file_name :String, mode :=File.WRITE) -> File:
	var file_path := create_temp_dir(relative_path) + "/" + file_name
	var file := File.new()
	var error = file.open(file_path, mode)
	if error == OK:
		_files_to_close.append(file)
		return file
	push_error("Error creating temporary file at: %s, %s" % [file_path, error_as_string(error)])
	return null


static func current_dir() -> String:
	return ProjectSettings.globalize_path("res://")


static func delete_directory(path :String, only_content := false) -> void:
	var dir := Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name := "."
		while file_name != "":
			file_name = dir.get_next()
			if file_name.empty() or file_name == "." or file_name == "..":
				continue
			var next := path + "/" +file_name
			if dir.current_is_dir():
				delete_directory(next)
			else:
				# delete file
				var err = Directory.new().remove(next)
				if err:
					push_error("Delete %s failed: %s" % [next, error_as_string(err)])
		if not only_content:
			var err := Directory.new().remove(path)
			if err:
				push_error("Delete %s failed: %s" % [path, error_as_string(err)])


static func copy_file(from_file :String, to_dir :String) -> Result:
	var dir := Directory.new()
	if dir.open(to_dir) == OK:
		var to_file := to_dir + "/" + from_file.get_file()
		prints("Copy %s to %s" % [from_file, to_file])
		var error = dir.copy(from_file, to_file)
		if error != OK:
			return Result.error("Can't copy file form '%s' to '%s'. Error: '%s'" % [from_file, to_file, error_as_string(error)])
		return Result.success(to_file)
	return Result.error("Directory not found: " + to_dir)


static func copy_directory(from_dir :String, to_dir :String, recursive :bool = false) -> bool:
	var source_dir := Directory.new()
	if not source_dir.dir_exists(from_dir):
		push_error("Source directory not found '%s'" % from_dir)
		return false
		
	# check if destination exists 
	var dest_dir := Directory.new()
	if not dest_dir.dir_exists(to_dir):
		# create it
		var err := dest_dir.make_dir_recursive(to_dir)
		if err != OK:
			push_error("Can't create directory '%s'. Error: %s" % [to_dir, error_as_string(err)])
			return false
	dest_dir.open(to_dir)
	
	if source_dir.open(from_dir) == OK:
		source_dir.list_dir_begin()
		var next := "."
		
		while next != "":
			next = source_dir.get_next()
			if next == "" or next == "." or next == "..":
				continue
			var source := source_dir.get_current_dir() + "/" + next
			var dest := dest_dir.get_current_dir() + "/" + next
			if source_dir.current_is_dir():
				if recursive:
					copy_directory(source + "/", dest, recursive)
				continue
			var err = source_dir.copy(source, dest)
			if err != OK:
				push_error("Error on copy file '%s' to '%s'" % [source, dest])
				return false
		
		return true
	else:
		push_error("Directory not found: " + from_dir)
		return false

# scans given path for sub directories by given prefix and returns the highest index numer
# e.g. <prefix_%d>
static func find_last_path_index(path :String, prefix :String) -> int:
	var dir := Directory.new()
	if not dir.dir_exists(path):
		return 0
	var last_iteration := 0
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var next := "."
		while next != "":
			next = dir.get_next()
			if next.empty() or next == "." or next == "..":
				continue
			if next.begins_with(prefix):
				var iteration := int(next.split("_")[1])
				if iteration > last_iteration:
					last_iteration = iteration
	return last_iteration

static func delete_path_index_lower_equals_than(path :String, prefix :String, index :int) -> int:
	var dir := Directory.new()
	if not dir.dir_exists(path):
		return 0
	var deleted := 0
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var next := "."
		while next != "":
			next = dir.get_next()
			if next.empty() or next == "." or next == "..":
				continue
			if next.begins_with(prefix):
				var current_index := int(next.split("_")[1])
				if current_index <= index:
					deleted += 1
					delete_directory(path + "/" + next)
	return deleted


static func _list_installed_tar_paths() -> PoolStringArray:
	var stdout = Array()
	OS.execute("where", ["tar"], true, stdout)
	if stdout.size() > 0:
		return PoolStringArray(stdout[0].split("\n"))
	return PoolStringArray()

static func _find_tar_path(os_name :String) -> String:
	if os_name.to_upper() != "WINDOWS":
		return "tar"
	var paths := _list_installed_tar_paths()
	for path in paths:
		if path.find("\\System32\\tar") != -1:
			return path.strip_escapes()
	return "tar"

static func extract_package(source :String, dest:String) -> Result:
	prints("Detect OS :", OS.get_name())
	var tar_path := _find_tar_path( OS.get_name())
	var err = OS.execute(tar_path, ["-xf", source, "-C", dest])
	if err != 0:
		var cmd = "%s -xf \"%s\" -C \"%s\"" % [tar_path, source, dest]
		prints("Extracting by `%s` failed with error code: %d" % [cmd, err])
		prints("Fallback to unzip")
		err = OS.execute("unzip", [source, "-d", dest])
		if err != 0:
			cmd = "unzip %s -d %s" % [source, dest]
			prints("Extracting by `%s` failed with error code: %d" % [cmd, err])
			return Result.error("Extracting `%s` failed! Please collect the error log and report this." % source)
	prints("%s successfully extracted" % source)
	return Result.success(dest)


static func scan_dir(path :String) -> PoolStringArray:
	var dir := Directory.new()
	if not dir.dir_exists(path):
		return PoolStringArray()
	var content := PoolStringArray()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var next := "."
		while next != "":
			next = dir.get_next()
			if next.empty() or next == "." or next == "..":
				continue
			content.append(next)
	return content

static func resource_as_array(resource_path :String) -> PoolStringArray:
	var file := File.new()
	var err := file.open(resource_path, File.READ)
	if err != OK:
		push_error("ERROR: Can't read resource '%s'. %s" % [resource_path, error_as_string(err)])
		return PoolStringArray()
	var file_content := PoolStringArray()
	while not file.eof_reached():
		file_content.append(file.get_line())
	file.close()
	return file_content

static func resource_as_string(resource_path :String) -> String:
	var file := File.new()
	var err := file.open(resource_path, File.READ)
	if err != OK:
		push_error("ERROR: Can't read resource '%s'. %s" % [resource_path, error_as_string(err)])
		return ""
	var file_content := file.get_as_text()
	file.close()
	return file_content

static func normalize_text(text :String) -> String:
	return text.replace("\r", "");


static func free_instance(instance :Object):
	# needs to manually exculde JavaClass
	# see https://github.com/godotengine/godot/issues/44932
	if is_instance_valid(instance) and not(instance is JavaClass):
		if not instance is Reference:
			release_double(instance)
			instance.free()
		else:
			instance.notification(Object.NOTIFICATION_PREDELETE)
			release_double(instance)
 
# if instance an mock or spy we need manually freeing the self reference
static func release_double(instance :Object):
	var fr := funcref(instance, "__release_double")
	if fr.is_valid():
		fr.call_func()

# register an instance to be freed when a test suite is finished
static func register_auto_free(obj, pool :int):
	# only register real object values
	if not obj is Object:
		return obj
	# only register pure objects
	#prints("register_auto_free on Pool", pool, obj)
	_objects_to_delete[pool].append(obj)
	return obj

# runs over all registered objects and frees it
static func run_auto_free(pool :int):
	var obj_pool := _objects_to_delete[pool] as Array
	#prints("run_auto_free on Pool:", pool, obj_pool.size())
	while not obj_pool.empty():
		var obj = obj_pool.pop_front()
		free_instance(obj)

# tests if given object is registered for auto freeing
static func is_auto_free_registered(obj, pool :int) -> bool:
	# only register real object values
	if not obj is Object:
		return false
	var obj_pool := _objects_to_delete[pool] as Array
	return obj_pool.has(obj)


# test is given object a valid 'GDScriptFunctionState'
static func is_yielded(obj) -> bool:
	return obj is GDScriptFunctionState and obj.is_valid()

# runs over all registered files and closes it
static func run_auto_close():
	while not _files_to_close.empty():
		var file := _files_to_close.pop_front() as File
		if file != null and file.is_open():
			#prints("auto close %s" % file.get_path_absolute())
			file.close()

static func make_qualified_path(path :String) -> String:
	if not path.begins_with("res://"):
		if path.begins_with("//"):
			return path.replace("//", "res://")
		if path.begins_with("/"):
			return "res:/" + path
	return path

static func error_as_string(error_number :int) -> String:
	if ENGINE_ENUM_MAPPINGS[ERRORS] == null:
		# initalizise error mapping on first call
		ENGINE_ENUM_MAPPINGS[ERRORS] = error_mapping()
	var mapping := ENGINE_ENUM_MAPPINGS[ERRORS] as Dictionary
	if mapping.has(error_number):
		return mapping[error_number]
	return "Unknown error number %s" % error_number
	
static func clear_push_errors() -> void:
	var runner = Engine.get_meta("GdUnitRunner")
	if runner != null:
		runner.clear_push_errors()

static func register_expect_interupted_by_timeout(test_suite :Node, test_case_name :String) -> void:
	var test_case = test_suite.find_node(test_case_name, false, false)
	test_case.expect_to_interupt()

static func append_array(array, append :Array) -> void:
	var major :int = Engine.get_version_info()["major"]
	var minor :int = Engine.get_version_info()["minor"]
	if major >= 3 and minor >= 3:
		array.append_array(append)
	else:
		for element in append:
			array.append(element)

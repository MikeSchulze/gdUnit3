# A class doubler used to mock and spy on implementations
class_name GdUnitClassDoubler
extends Reference

const EXCLUDE_VIRTUAL_FUNCTIONS = [
	# Object
	#"_get", 
	#"_get_property_list", 
	#"_init", 
	#"_enter_tree",
	#"_exit_tree",
	#"_unhandled_key_input",
	#"_unhandled_input",
	"_notification", 
	#"_process",
	#"_physics_process",
	#"_set", 
	#"_to_string",
	# Resource
	#"_setup_local_to_scene",
	]

# define functions to be exclude when spy or mock on a scene
const EXLCUDE_SCENE_FUNCTIONS = [
	# needs to exclude get/set script functions otherwise it endsup in recursive endless loop
	"set_script",
	"get_script",
	"get_class",
	# exclude virtual functions where used by initalizise the scene
	#"_enter_tree",
	#"_exit_tree",
	#"_ready",
	#"_get_minimum_size",
	#"_override_changed",
	#"_theme_changed",
	#"_draw",
	#"_input",
	#"_physics_process",
	#"_process",
	#"_unhandled_key_input",
	"_unhandled_input",
	#"_gui_input"
]

const EXCLUDE_FUNCTIONS = ["new", "free", "get_instance_id", "get_tree"]

# loads the doubler template
static func load_template(template :Object, clazz_name :String, clazz_path :PoolStringArray) -> PoolStringArray:
	var source_code = template.new().get_script().source_code
	var lines := GdScriptParser.to_unix_format(source_code).split("\n")
	# replace template class_name with Doubled<class> name and extends form source class
	lines.remove(2)
	lines.insert(2, "class_name Doubled%s" % clazz_name.replace(".", "_"))
	lines.insert(3, "extends %s" % get_extends_clazz(clazz_name, clazz_path))
	
	var eol := lines.size()
	# append Object interactions stuff
	source_code = GdUnitObjectInteractionsTemplate.new().get_script().source_code
	lines += GdScriptParser.to_unix_format(source_code).split("\n")
	# remove the class header from GdUnitObjectInteractionsTemplate
	lines.remove(eol)
	return lines

static func get_extends_clazz(clazz_name :String, clazz_path :PoolStringArray) -> String:
	# is godot class use original class name
	if ClassDB.class_exists(clazz_name):
		return clazz_name
	# if class publc (defined by class_name <clazz_name>)
	if GdObjects.is_public_script_class(clazz_name):
		return clazz_name
	# is inner class use inner class name
	if "." in clazz_name:
		return clazz_name
	# for not public script classes use the full class path
	if not clazz_path.empty():
		return "'%s'" % clazz_path[0]
	return clazz_name

# double all functions of given instance
static func double_functions(clazz_name :String, clazz_path :PoolStringArray, func_doubler: GdFunctionDoubler, exclude_functions :Array) -> PoolStringArray:
	var doubled_source := PoolStringArray()
	var parser := GdScriptParser.new()
	var exclude_override_functions := EXCLUDE_VIRTUAL_FUNCTIONS + EXCLUDE_FUNCTIONS + exclude_functions
	var functions := Array()
	# double script functions
	if not ClassDB.class_exists(clazz_name):
		var result := parser.parse(clazz_name, clazz_path)
		if result.is_error():
			push_error(result.error_message())
			return PoolStringArray()
		var class_descriptor :GdClassDescriptor = result.value()
		while class_descriptor != null:
			for func_descriptor in class_descriptor.functions():
				if functions.has(func_descriptor.name()) or exclude_override_functions.has(func_descriptor.name()):
					continue
				doubled_source += func_doubler.double(func_descriptor)
				functions.append(func_descriptor.name())
			class_descriptor = class_descriptor.parent()
		
	# double regular class functions
	var clazz_functions := GdObjects.extract_class_functions(clazz_name, clazz_path)
	for method in clazz_functions:
		var func_descriptor := GdFunctionDescriptor.extract_from(method)
		if functions.has(func_descriptor.name()) or exclude_override_functions.has(func_descriptor.name()):
			continue
		functions.append(func_descriptor.name())
		doubled_source += func_doubler.double(func_descriptor)
	
	return doubled_source

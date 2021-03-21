# A class doubler used to mock and spy on implementations
class_name GdUnitClassDoubler
extends Reference

const EXCLUDE_VIRTUAL_FUNCTIONS = [
	# Object
	"_get", 
	"_get_property_list", 
	#"_init", 
	"_notification", 
	"_set", 
	"_to_string",
	# Resource
	"_setup_local_to_scene"]
const EXCLUDE_FUNCTIONS = ["new", "free", "get_instance_id"]

static func extract_class_functions(clazz_name :String, script_path :PoolStringArray) -> Array:
	#prints("extract_class_functions", clazz_name)
	if ClassDB.class_get_method_list(clazz_name):
		return ClassDB.class_get_method_list(clazz_name)
	
	var script = load(script_path[0])
	var clazz_functions :Array = script.get_method_list()
	if script is GDScript:
		var base_clazz :String = script.get_instance_base_type()
		if base_clazz:
			return extract_class_functions(base_clazz, script_path)
	return clazz_functions

# loads the doubler template
static func load_template(template :Object, clazz :String) -> PoolStringArray:
	var source_code = template.new().get_script().source_code
	var lines := GdScriptParser.to_unix_format(source_code).split("\n")
	# replace template class_name with Doubled<class> name and extends form source class
	lines.remove(2)
	lines.insert(2, "class_name Doubled%s" % clazz.replace(".", "_"))
	lines.insert(3, "extends %s" % clazz)
	
	var eol := lines.size()
	# append Object interactions stuff
	source_code = GdUnitObjectInteractionsTemplate.new().get_script().source_code
	lines += GdScriptParser.to_unix_format(source_code).split("\n")
	# remove the class header from GdUnitObjectInteractionsTemplate
	lines.remove(eol)
	return lines

# double all functions of given instance
static func double_functions(clazz_name :String, clazz_path :PoolStringArray, func_doubler: GdFunctionDoubler) -> PoolStringArray:
	var doubled_source := PoolStringArray()
	var parser := GdScriptParser.new()
	
	var exclude_override_functions := EXCLUDE_VIRTUAL_FUNCTIONS + EXCLUDE_FUNCTIONS
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
	var clazz_functions := extract_class_functions(clazz_name, clazz_path)
	for method in clazz_functions:
		var func_descriptor := GdFunctionDescriptor.extract_from(method)
		if functions.has(func_descriptor.name()) or exclude_override_functions.has(func_descriptor.name()):
			continue
		functions.append(func_descriptor.name())
		doubled_source += func_doubler.double(func_descriptor)
	
	return doubled_source

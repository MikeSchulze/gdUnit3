class_name GdUnitMockBuilder
extends GdUnitClassDoubler

const MOCK_TEMPLATE =\
"""	var args :Array = ["$(func_name)"] + $(args)
	var default_return_value = ${default_return_value}
	
	if $(instance)__is_prepare_return_value():
		return $(instance)__save_function_return_value(args)
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return ${default_return_value}
	else:
		$(instance)__save_function_interaction(args)
	
	if $(instance)__saved_return_values.has(args):
		return $(instance)__saved_return_values.get(args)
	
	if $(is_virtual) == false and $(instance)__working_mode == GdUnitMock.CALL_REAL_FUNC:
		return .$(func_name)($(func_arg))
	return ${default_return_value}
"""

const MOCK_VOID_TEMPLATE =\
"""	var args :Array = ["$(func_name)"] + $(args)
	
	if $(instance)__is_prepare_return_value():
		if $(push_errors):
			push_error(\"Mocking a void function '$(func_name)(<args>) -> void:' is not allowed.\")
		return
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	if $(is_virtual) == false and $(instance)__working_mode == GdUnitMock.CALL_REAL_FUNC:
		.$(func_name)($(func_arg))
"""

const MOCK_VOID_TEMPLATE_VARARG =\
"""	var varargs :Array = __filter_vargs($(varargs))
	var args :Array = ["$(func_name)"] + $(args) + varargs
	
	if $(instance)__is_prepare_return_value():
		if $(push_errors):
			push_error(\"Mocking a void function '$(func_name)(<args>) -> void:' is not allowed.\")
		return
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	if $(is_virtual) == false and $(instance)__working_mode == GdUnitMock.CALL_REAL_FUNC:
		match varargs.size():
			0: .$(func_name)($(func_arg))
			1: .$(func_name)($(func_arg), varargs[0])
			2: .$(func_name)($(func_arg), varargs[0], varargs[1])
			3: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2])
			4: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3])
			5: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
			6: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
			7: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
			8: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
			9: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
			10: .$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
"""

const MOCK_VOID_TEMPLATE_VARARG_ONLY =\
"""	var varargs :Array = __filter_vargs($(varargs))
	var args :Array = ["$(func_name)"] + varargs
	
	if $(instance)__is_prepare_return_value():
		if $(push_errors):
			push_error(\"Mocking a void function '$(func_name)(<args>) -> void:' is not allowed.\")
		return
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	if $(is_virtual) == false and $(instance)__working_mode == GdUnitMock.CALL_REAL_FUNC:
		match varargs.size():
			0: .$(func_name)()
			1: .$(func_name)(varargs[0])
			2: .$(func_name)(varargs[0], varargs[1])
			3: .$(func_name)(varargs[0], varargs[1], varargs[2])
			4: .$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3])
			5: .$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
			6: .$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
			7: .$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
			8: .$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
			9: .$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
			10: .$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
"""

class MockFunctionDoubler extends GdFunctionDoubler:
	var _push_errors :String
	
	func _init(push_errors :bool):
		_push_errors = "true" if push_errors else "false"
	
	func double(func_descriptor :GdFunctionDescriptor) -> PoolStringArray:
		var func_signature := func_descriptor.typeless()
		var is_virtual := func_descriptor.is_virtual()
		var is_static := func_descriptor.is_static()
		var is_vararg := func_descriptor.is_vararg()
		var func_name := func_descriptor.name()
		var args := func_descriptor.args()
		var varargs := func_descriptor.varargs()
		var default_return_value = return_value(func_descriptor.return_type())
		var arg_names := extract_arg_names(args)
		var vararg_names := extract_arg_names(varargs)
		
		# save original constructor arguments
		if func_name == "_init":
			var constructor_args := extract_constructor_args(args).join(",")
			var constructor := "func _init(%s).(%s):\n	pass\n" % [constructor_args, arg_names.join(",")]
			return PoolStringArray([constructor])
		
		var double := func_signature + "\n"
		var func_template := get_template(default_return_value, is_vararg, not arg_names.empty())
		# fix to  unix format, this is need when the template is edited under windows than the template is stored with \r\n
		func_template = GdScriptParser.to_unix_format(func_template)
		double += func_template\
			.replace("$(args)", str(arg_names)) \
			.replace("$(varargs)", str(vararg_names)) \
			.replace("$(is_virtual)", str(is_virtual).to_lower()) \
			.replace("$(func_name)", func_name )\
			.replace("$(func_arg)", arg_names.join(", "))\
			.replace("${default_return_value}", default_return_value)\
			.replace("$(push_errors)", _push_errors)
		if is_static:
			double = double.replace("$(instance)", "__self[0].")
		else:
			double = double.replace("$(instance)", "")
		return double.split("\n")
	
	func get_template(return_type, is_vararg :bool, has_args :bool) -> String:
		if is_vararg and has_args:
			return MOCK_VOID_TEMPLATE_VARARG
		if is_vararg and not has_args:
			return MOCK_VOID_TEMPLATE_VARARG_ONLY
		if return_type == "void":
			return MOCK_VOID_TEMPLATE
		return MOCK_TEMPLATE

# holds mocker runtime configuration
const _config = {
	"push_errors": true
}

static func do_push_errors(enabled :bool):
	_config["push_errors"] = enabled
	
static func is_push_error_enabled() -> bool:
	return _config["push_errors"]

static func build(caller :Object, clazz, mock_mode :String, debug_write = false):
	var memory_pool :int = caller.get_meta(GdUnitMemoryPool.META_PARAM)
	var push_errors := is_push_error_enabled()
	if not is_mockable(clazz, push_errors):
		return null
	
	if GdObjects.is_scene(clazz):
		return mock_on_scene(caller, clazz as PackedScene, memory_pool, debug_write)
	elif typeof(clazz) == TYPE_STRING and clazz.ends_with(".tscn"):
		return mock_on_scene(caller, load(clazz), memory_pool, debug_write)
	
	var mock = mock_on_script(clazz, mock_mode, memory_pool, [], debug_write)
	if mock == null:
		return null
	var mock_instance = mock.new()
	mock_instance.__set_singleton()
	mock_instance.__set_mode(mock_mode)
	mock_instance.__set_caller(caller)
	return GdUnitTools.register_auto_free(mock_instance, memory_pool)

static func mock_on_scene(caller :Object, scene :PackedScene, memory_pool :int, debug_write :bool) -> Object:
	var push_errors := is_push_error_enabled()
	if not scene.can_instance():
		if push_errors:
			push_error("Can't instanciate scene '%s'" % scene.resource_path)
		return null
	var scene_instance = scene.instance()
	# we can only mock on a scene with attached script
	if scene_instance.get_script() == null:
		if push_errors:
			push_error("Can't create a mockable instance for a scene without script '%s'" % scene.resource_path)
		GdUnitTools.free_instance(scene_instance)
		return null
	
	var script_path = scene_instance.get_script().get_path()
	var mock = mock_on_script(script_path, GdUnitMock.CALL_REAL_FUNC, memory_pool, GdUnitClassDoubler.EXLCUDE_SCENE_FUNCTIONS, debug_write)
	if mock == null:
		return null
	scene_instance.set_script(mock)
	scene_instance.__set_singleton()
	scene_instance.__set_mode(GdUnitMock.CALL_REAL_FUNC)
	scene_instance.__set_caller(caller)
	return GdUnitTools.register_auto_free(scene_instance, memory_pool)

static func mock_on_script(clazz, mock_mode :String, memory_pool :int, function_excludes :PoolStringArray, debug_write :bool) -> GDScript:
	var clazz_name :String
	var clazz_path := GdObjects.extract_class_path(clazz)
	if clazz_path.empty():
		clazz_name = GdObjects.extract_class_name(clazz).value()
	else:
		clazz_name = GdObjects.extract_class_name_from_class_path(clazz_path)
	
	var push_errors := is_push_error_enabled()
	var function_doubler := MockFunctionDoubler.new(push_errors)
	var lines := load_template(GdUnitMockImpl, clazz_name, clazz_path)
	lines += double_functions(clazz_name, clazz_path, function_doubler, function_excludes)
	
	var mock := GDScript.new()
	mock.source_code = lines.join("\n")
	mock.resource_name = "Mock%s.gd" % clazz_name
	
	if debug_write:
		mock.resource_path = GdUnitTools.create_temp_dir("mock") + "/Mock%s.gd" % clazz_name
		Directory.new().remove(mock.resource_path)
		ResourceSaver.save(mock.resource_path, mock)
	var error = mock.reload(true)
	if error != OK:
		push_error("Critical!!!, MockBuilder error, please contact the developer.")
		return null
	return mock

static func is_mockable(clazz, push_errors :bool=false) -> bool:
	var clazz_type := typeof(clazz)
	if clazz_type != TYPE_OBJECT and clazz_type != TYPE_STRING:
		push_error("Invalid clazz type is used")
		return false
	# is PackedScene
	if GdObjects.is_scene(clazz):
		return true
	# verify class type
	if GdObjects.is_object(clazz):
		var mockable := false
		if GdObjects.is_instance(clazz):
			if push_errors:
				push_error("It is not allowed to mock an instance '%s', use class name instead, Read 'Mocker' documentation for details" % clazz)
			return false

		if not GdObjects.can_instance(clazz):
			if push_errors:
				push_error("Can't create a mockable instance for class '%s'" % clazz)
			return false
		return true
	# verify by class name on registered classes
	var clazz_name := clazz as String
	if ClassDB.class_exists(clazz_name):
		if Engine.has_singleton(clazz_name):
			if push_errors:
				push_error("Mocking a singelton class '%s' is not allowed!  Read 'Mocker' documentation for details" % clazz_name)
			return false
		if not ClassDB.can_instance(clazz_name):
			if push_errors:
				push_error("Mocking class '%s' is not allowed it cannot be instantiated!" % clazz_name)
			return false
		# exclude classes where name starts with a underscore
		if clazz_name.find("_") == 0:
			if push_errors:
				push_error("Can't create a mockable instance for protected class '%s'" % clazz_name)
			return false
		return true
	# at least try to load as a script
	var clazz_path := clazz_name
	if not File.new().file_exists(clazz_path):
		if push_errors:
			push_error("'%s' cannot be mocked for the specified resource path, the resource does not exist" % clazz_name)
		return false
	# finally verify is a script resource
	var resource = load(clazz_path)
	if resource == null:
		if push_errors:
			push_error("'%s' cannot be mocked the script cannot be loaded." % clazz_name)
			return false
	# finally check is extending from script
	return GdObjects.is_script(resource) or GdObjects.is_scene(resource)

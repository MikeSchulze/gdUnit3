class_name GdUnitMockBuilder
extends GdUnitClassDoubler

const MOCK_TEMPLATE =\
"""	var args = $(args)
	var default_return_value = ${default_return_value}
	
	#prints("--->", args)
	if $(instance)__is_prepare_return_value():
		return $(instance)__save_function_return_value(args)
	if $(instance)__is_verify():
		return $(instance)__verify(args, ${default_return_value})
	else:
		$(instance)__save_function_call_times(args)

	if $(instance)_saved_return_values.has(args):
		return $(instance)_saved_return_values.get(args)

	if $(instance)_working_mode == GdUnitMock.CALL_REAL_FUNC:
		return .$(func_name)($(func_arg))
	return ${default_return_value}
"""

const MOCK_VOID_TEMPLATE =\
"""	var args = $(args)
	
	#prints("--->", args)
	if $(instance)__is_prepare_return_value():
		if $(push_errors):
			push_error(\"Mocking a void function '$(func_name)(<args>) -> void:' is not allowed.\")
		return
	if $(instance)__is_verify():
		$(instance)__verify(args, null)
		return
	else:
		$(instance)__save_function_call_times(args)
	
	if $(instance)_working_mode == GdUnitMock.CALL_REAL_FUNC:
		.$(func_name)($(func_arg))
"""

class MockFunctionDoubler extends GdFunctionDoubler:
	var _push_errors :String
	
	func _init(push_errors :bool):
		_push_errors = "true" if push_errors else "false"
	
	func double(func_descriptor :GdFunctionDescriptor) -> PoolStringArray:
		var func_signature := func_descriptor.typeless()
		var is_static := func_descriptor.is_static()
		var func_name := func_descriptor.name()
		var args := func_descriptor.args()
		var default_return_value = return_value(func_descriptor.return_type())
		var arg_names := extract_arg_names(args)
		# save original constructor arguments
		if func_name == "_init":
			var constructor_args := extract_constructor_args(args).join(",")
			var constructor := "func _init(%s).(%s):\n	pass\n" % [constructor_args, arg_names.join(",")]
			return PoolStringArray([constructor])
		
		var full_args := Array(arg_names)
		full_args.push_front("\"%s\"" % func_name)
		var double := func_signature + "\n"
		
		double += get_template(default_return_value)\
			.replace("$(args)", str(full_args)) \
			.replace("$(func_name)", func_name )\
			.replace("$(func_arg)", arg_names.join(","))\
			.replace("${default_return_value}", default_return_value)\
			.replace("$(push_errors)", _push_errors)
		if is_static:
			double = double.replace("$(instance)", "_self[0].")
		else:
			double = double.replace("$(instance)", "")
		return double.split("\n")
	
	func get_template(return_type) -> String:
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

static func build(clazz, mock_mode :String, memory_pool :int, debug_write = false):
	var push_errors := is_push_error_enabled()
	if not is_mockable(clazz, push_errors):
		return null
	
	var clazz_name :String
	var clazz_path := GdObjects.extract_class_path(clazz)
	if clazz_path.empty():
		clazz_name = GdObjects.extract_class_name(clazz).value()
	else:
		clazz_name = GdObjects.extract_class_name_from_class_path(clazz_path)
	
	var function_doubler := MockFunctionDoubler.new(push_errors)
	var lines := load_template(GdUnitMockImpl, clazz_name)
	lines += double_functions(clazz_name, clazz_path, function_doubler)
	
	var mock := GDScript.new()
	mock.source_code = lines.join("\n")
	
	if debug_write:
		mock.resource_path = GdUnitTools.create_temp_dir("mock") + "/Mock%s.gd" % clazz_name
		Directory.new().remove(mock.resource_path)
		ResourceSaver.save(mock.resource_path, mock)
	var error = mock.reload(true)
	if error != OK:
		push_error("Critical!!!, MockBuilder error, please contact the developer.")
		return null
		
	var mock_instance = mock.new()
	mock_instance.__set_singleton()
	mock_instance.__set_mode(mock_mode)
	return GdUnitTools.register_auto_free(mock_instance, memory_pool)

static func is_mockable(clazz, push_errors :bool=false) -> bool:
	var clazz_type := typeof(clazz)
	if clazz_type != TYPE_OBJECT and clazz_type != TYPE_STRING:
		push_error("Invalid clazz type is used")
		return false
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
	if resource is Script:
		return true
	return false

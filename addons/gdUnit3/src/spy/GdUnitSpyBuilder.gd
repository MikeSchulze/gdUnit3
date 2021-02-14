class_name GdUnitSpyBuilder
extends GdUnitClassDoubler

const SPY_TEMPLATE = \
"""	var args = $(args)
	
	#prints("--->", args)
	if $(instance)__is_verify():
		return $(instance)__verify(args)
	else:
		$(instance)__save_function_call(args)
	return $(instance)_instance_delegator.$(func_name)($(func_arg))
"""

class SpyFunctionDoubler extends GdFunctionDoubler:
	
	
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
		double += SPY_TEMPLATE.replace("$(args)", str(full_args)) \
			.replace("$(func_name)", func_name )\
			.replace("$(func_arg)", arg_names.join(","))
		if is_static:
			double = double.replace("$(instance)", "_self[0].")
		else:
			double = double.replace("$(instance)", "")
		return double.split("\n")


static func build(instance, memory_pool :int, push_errors :bool = true, debug_write = false):
	var result := GdObjects.extract_class_name(instance)
	if result.is_error():
		push_error("Internal ERROR: %s" % result.error_message())
		return null
	var extends_clazz := result.value() as String
	
	if GdObjects.is_array_type(instance):
		push_error("Can't build spy on type '%s'! Spy on Container Built-In Type not supported!" % extends_clazz)
		return null
		
	if not GdObjects.is_instance(instance):
		push_error("Can't build spy for class type '%s'! Using an instance instead e.g. 'spy(<instance>)'" % [extends_clazz])
		return null
	
	var lines := load_template(GdUnitSpyImpl, extends_clazz)
	var clazz_path := GdObjects.extract_class_path(instance)
	lines += double_functions(extends_clazz, clazz_path, SpyFunctionDoubler.new())

	var spy := GDScript.new()
	spy.source_code = lines.join("\n")
	
	if debug_write:
		GdUnitTools.create_temp_dir("mocked")
		spy.resource_path = GdUnitTools.create_temp_dir("spy") + "/Spy%s.gd" % extends_clazz
		Directory.new().remove(spy.resource_path)
		ResourceSaver.save(spy.resource_path, spy)
	var error = spy.reload(true)
	if error != OK:
		push_error("Unexpected Error!, SpyBuilder error, please contact the developer.")
		return null
	var spy_instance = spy.new()
	spy_instance.__set_singleton(instance)
		
	return GdUnitTools.register_auto_free(spy_instance, memory_pool)

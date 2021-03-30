class_name GdUnitSpyBuilder
extends GdUnitClassDoubler

const SPY_TEMPLATE = \
"""	var args :Array = ["$(func_name)"] + $(args)
	
	if $(instance)__is_verify_interactions():
		return $(instance)__verify_interactions(args)
	else:
		$(instance)__save_function_interaction(args)
	return $(instance_delegator).$(func_name)($(func_arg))
"""

const SPY_VOID_TEMPLATE = \
"""	var args :Array = ["$(func_name)"] + $(args)
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	$(instance_delegator).$(func_name)($(func_arg))
"""

const SPY_VOID_TEMPLATE_VARARG =\
"""	var varargs :Array = __filter_vargs($(varargs))
	var args :Array = ["$(func_name)"] + $(args) + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	match varargs.size():
		0: $(instance_delegator).$(func_name)($(func_arg))
		1: $(instance_delegator).$(func_name)($(func_arg), varargs[0])
		2: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1])
		3: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2])
		4: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3])
		5: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
		6: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
		7: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
		8: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
		9: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
		10: $(instance_delegator).$(func_name)($(func_arg), varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
"""

const SPY_VOID_TEMPLATE_VARARG_ONLY =\
"""	var varargs :Array = __filter_vargs($(varargs))
	var args :Array = ["$(func_name)"] + varargs
	
	if $(instance)__is_verify_interactions():
		$(instance)__verify_interactions(args)
		return
	else:
		$(instance)__save_function_interaction(args)
	
	match varargs.size():
		0: $(instance_delegator).$(func_name)()
		1: $(instance_delegator).$(func_name)(varargs[0])
		2: $(instance_delegator).$(func_name)(varargs[0], varargs[1])
		3: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2])
		4: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3])
		5: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4])
		6: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5])
		7: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6])
		8: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7])
		9: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8])
		10: $(instance_delegator).$(func_name)(varargs[0], varargs[1], varargs[2], varargs[3], varargs[4], varargs[5], varargs[6], varargs[7], varargs[8], varargs[9])
"""

class SpyFunctionDoubler extends GdFunctionDoubler:
	
	
	func double(func_descriptor :GdFunctionDescriptor) -> PoolStringArray:
		var func_signature := func_descriptor.typeless()
		var is_static := func_descriptor.is_static()
		var is_engine := func_descriptor.is_engine()
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
			.replace("$(args)", str(arg_names))\
			.replace("$(varargs)", str(vararg_names)) \
			.replace("$(func_name)", func_name )\
			.replace("$(func_arg)", arg_names.join(", "))
		
		if is_static:
			double = double.replace("$(instance_delegator)", "__self[0].__instance_delegator" if is_engine else "")\
				.replace("$(instance)", "__self[0].")
		else:
			double = double.replace("$(instance_delegator)", "__instance_delegator" if is_engine else "")\
				.replace("$(instance)", "")
		return double.split("\n")
		
	func get_template(return_type, is_vararg :bool, has_args :bool) -> String:
		if is_vararg and has_args:
			return SPY_VOID_TEMPLATE_VARARG
		if is_vararg and not has_args:
			return SPY_VOID_TEMPLATE_VARARG_ONLY
		if return_type == "void":
			return SPY_VOID_TEMPLATE
		return SPY_TEMPLATE


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
	
	var clazz_path := GdObjects.extract_class_path(instance)
	var lines := load_template(GdUnitSpyImpl, extends_clazz, clazz_path)
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

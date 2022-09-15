class_name GdTestParameterSetValidator
extends Reference

static func validate(input_arguments :Array) -> String:
	var input_values_arg :GdFunctionArgument = GdFunctionArgument.get_parameter_set(input_arguments)
	if input_values_arg == null:
		return "No argument '%s' found for parameterized test." % GdFunctionArgument.ARG_PARAMETERIZED_TEST
	input_arguments.erase(input_values_arg)
	
	var input_value_set :Array = str2var(input_values_arg.default())
	# check given parameter set with test case arguments
	var expected_arg_count = input_arguments.size()
	for input_values in input_value_set:
		var parameter_set_index := input_value_set.find(input_values)
		if input_values is Array:
			var current_arg_count = input_values.size()
			if current_arg_count != expected_arg_count:
				return "\n	The parameter set at index [%d] does not match the expected input parameters!\n	The test case requires [%d] input parameters, but the set contains [%d]" % [parameter_set_index, expected_arg_count, current_arg_count]
			var error := validate_parameter_types(input_arguments, input_values, parameter_set_index)
			if not error.empty():
				return error
		else:
			return "\n	The parameter set at index [%d] does not match the expected input parameters!\n	Expecting an array of input values." % parameter_set_index
	return ""

static func validate_parameter_types(input_arguments :Array, input_values :Array, parameter_set_index :int) -> String:
	for i in input_arguments.size():
		var input_param :GdFunctionArgument = input_arguments[i]
		var input_param_type := GdObjects.string_as_typeof(input_param.type())
		var input_value = input_values[i]
		var input_value_type := typeof(input_value)
		if input_param_type != input_value_type:
			return "\n	The parameter set at index [%d] does not match the expected input parameters!\n	The value '%s' does not match the required input parameter <%s>." % [parameter_set_index, input_value, input_param]
	return ""

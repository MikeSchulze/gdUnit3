class_name GdTestParameterSet
extends Reference

const Vector2_ZERO 		= "Vector2(0,0)"
const Vector2_ONE 		= "Vector2(1,1)"
const Vector2_RIGHT 	= "Vector2(1,0)"
const Vector2_LEFT 		= "Vector2(-1,0)"
const Vector2_DOWN 		= "Vector2(0,1)"
const Vector2_UP 		= "Vector2(0,-1)"
const Vector2_INF 		= "Vector2(1.#INF,1.#INF)"

const Vector3_ZERO 		= "Vector3(0,0,0)"
const Vector3_ONE 		= "Vector3(1,1,1)"
const Vector3_RIGHT 	= "Vector3(1,0,0)"
const Vector3_LEFT 		= "Vector3(-1,0,0)"
const Vector3_UP 		= "Vector3(0,1,0)"
const Vector3_DOWN 		= "Vector3(0,-1,0)"
const Vector3_BACK 		= "Vector3(0,0,1)"
const Vector3_FORWARD 	= "Vector3(0,0,-1)"
const Vector3_INF 		= "Vector3(1.#INF,1.#INF,1.#INF)"

# extraxts the input value set from given arguments
static func get_input_values(input_arguments :Array) -> Array:
	var input_values_arg :GdFunctionArgument = GdFunctionArgument.get_parameter_set(input_arguments)
	if input_values_arg == null:
		return []
	# we need to replace constants with stringified values otherwise 'str2var' fails
	var value = _convert_vector2_constants(input_values_arg.default())
	value = _convert_vector3_constants(value)
	return str2var(value) as Array

static func _convert_vector2_constants(value :String) -> String:
	if value.find("Vector2") == -1:
		return value
	return value\
		.replace("Vector2.ZERO", Vector2_ZERO)\
		.replace("Vector2.ONE", Vector2_ONE)\
		.replace("Vector2.LEFT", Vector2_LEFT)\
		.replace("Vector2.RIGHT", Vector2_RIGHT)\
		.replace("Vector2.UP", Vector2_UP)\
		.replace("Vector2.DOWN", Vector2_DOWN)\
		.replace("Vector2.INF", Vector2_INF)\

static func _convert_vector3_constants(value :String) -> String:
	if value.find("Vector3") == -1:
		return value
	return value\
		.replace("Vector3.ZERO", Vector3_ZERO)\
		.replace("Vector3.ONE", Vector3_ONE)\
		.replace("Vector3.LEFT", Vector3_LEFT)\
		.replace("Vector3.RIGHT", Vector3_RIGHT)\
		.replace("Vector3.UP", Vector3_UP)\
		.replace("Vector3.DOWN", Vector3_DOWN)\
		.replace("Vector3.FORWARD", Vector3_FORWARD)\
		.replace("Vector3.BACK", Vector3_BACK)\
		.replace("Vector3.INF", Vector3_INF)\

# validates the given arguments are complete and matches to required input fields of the test function
static func validate(input_arguments :Array) -> String:
	var input_value_set := get_input_values(input_arguments)
	if input_value_set == null:
		return "No argument '%s' found for parameterized test." % GdFunctionArgument.ARG_PARAMETERIZED_TEST
	# check given parameter set with test case arguments
	var expected_arg_count = input_arguments.size() - 1
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
		# only check the test input arguments
		if input_param.is_parameter_set():
			continue
		var input_param_type := GdObjects.string_as_typeof(input_param.type())
		var input_value = input_values[i]
		var input_value_type := typeof(input_value)
		if input_param_type != input_value_type:
			return "\n	The parameter set at index [%d] does not match the expected input parameters!\n	The value '%s' does not match the required input parameter <%s>." % [parameter_set_index, input_value, input_param]
	return ""

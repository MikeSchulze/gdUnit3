class_name GdScriptParser
extends Reference


const ALLOWED_CHARACTERS := "0123456789_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\""

var TOKEN_NOT_MATCH := Token.new("")
var TOKEN_SPACE := Token.new(" ")
var TOKEN_COMMENT := Token.new("#")
var TOKEN_CLASS_NAME := Token.new("class_name")
var TOKEN_INNER_CLASS := Token.new("class")
var TOKEN_EXTENDS := Token.new("extends")
var TOKEN_ENUM := Token.new("enum")
var TOKEN_FUNCTION_STATIC_DECLARATION := Token.new("staticfunc")
var TOKEN_FUNCTION_DECLARATION := Token.new("func")
var TOKEN_FUNCTION := Token.new(".")
var TOKEN_FUNCTION_RETURN_TYPE := Token.new("->")
var TOKEN_ARGUMENT_ASIGNMENT := Token.new("=")
var TOKEN_ARGUMENT_TYPE_ASIGNMENT := Token.new(":=")
var TOKEN_TEST_TIMEOUT := Token.new("timeout")
var TOKEN_FUZZER_ITERATIONS := Token.new("fuzzer_iterations")
var TOKEN_FUZZER_SEED := Token.new("fuzzer_seed")
var TOKEN_ARGUMENT_FUZZER_ASIGNMENT1 := regex_token("fuzzer(|[a-z,A-Z,0-9,_]+):Fuzzer=")
var TOKEN_ARGUMENT_FUZZER_ASIGNMENT2 := regex_token("fuzzer(|[a-z,A-Z,0-9,_]+):=")
var TOKEN_ARGUMENT_FUZZER_ASIGNMENT3 := regex_token("fuzzer(|[a-z,A-Z,0-9,_]+)=")
var TOKEN_ARGUMENT_TYPE := Token.new(":")
var TOKEN_ARGUMENT_SEPARATOR := Token.new(",")
var TOKEN_BRACKET_OPEN := Token.new("(")
var TOKEN_BRACKET_CLOSE := Token.new(")")
var TOKEN_NEW_LINE := Token.new("\n")

var OPERATOR_ADD := Operator.new("+")
var OPERATOR_SUB := Operator.new("-")
var OPERATOR_MUL := Operator.new("*")
var OPERATOR_DIV := Operator.new("/")
var OPERATOR_REMAINDER := Operator.new("%")

var TOKENS := [
	TOKEN_SPACE,
	TOKEN_COMMENT,
	TOKEN_BRACKET_OPEN,
	TOKEN_BRACKET_CLOSE,
	TOKEN_CLASS_NAME,
	TOKEN_INNER_CLASS,
	TOKEN_EXTENDS,
	TOKEN_ENUM,
	TOKEN_FUNCTION_STATIC_DECLARATION,
	TOKEN_FUNCTION_DECLARATION,
	TOKEN_TEST_TIMEOUT,
	TOKEN_FUZZER_ITERATIONS,
	TOKEN_FUZZER_SEED,
	TOKEN_ARGUMENT_FUZZER_ASIGNMENT1,
	TOKEN_ARGUMENT_FUZZER_ASIGNMENT2,
	TOKEN_ARGUMENT_FUZZER_ASIGNMENT3,
	TOKEN_ARGUMENT_TYPE_ASIGNMENT,
	TOKEN_ARGUMENT_ASIGNMENT,
	TOKEN_ARGUMENT_TYPE,
	TOKEN_FUNCTION,
	TOKEN_ARGUMENT_SEPARATOR,
	TOKEN_FUNCTION_RETURN_TYPE,
	TOKEN_NEW_LINE,

	OPERATOR_ADD,
	OPERATOR_SUB,
	OPERATOR_MUL,
	OPERATOR_DIV,
	OPERATOR_REMAINDER,
]

var FUZZER_TOKENS = [
	TOKEN_ARGUMENT_FUZZER_ASIGNMENT1,
	TOKEN_ARGUMENT_FUZZER_ASIGNMENT2,
	TOKEN_ARGUMENT_FUZZER_ASIGNMENT3
]

var _regex_clazz_name :RegEx

var _base_clazz :String
var _scanned_inner_classes := PoolStringArray()

static func prepare_regex(pattern :String) -> RegEx:
	var regex := RegEx.new()
	var err := regex.compile(pattern)
	if err != OK:
		push_error("Can't compiling regx '%s'.\n ERROR: %s" % [pattern, GdUnitTools.error_as_string(err)])
	return regex

static func clean_up_row(row :String) -> String:
	return to_unix_format(row.replace(" ", "").replace("	", ""))

static func to_unix_format(input :String) -> String:
	return input.replace("\r\n", "\n")

static func regex_token(token :String) -> Token:
	return Token.new(token, false, prepare_regex(token))

class Token extends Reference:
	var _token: String
	var _consumed: int
	var _is_operator: bool
	var _regex :RegEx

	func _init(token: String, is_operator:= false, regex :RegEx=null) -> void:
		_token = token
		_is_operator = is_operator
		_consumed = token.length()
		_regex = regex
	
	func match(input: String, pos: int) -> bool:
		if _regex:
			var result := _regex.search(input, pos)
			if result == null:
				return false
			_consumed = result.get_end() - result.get_start()
			return pos == result.get_start()
		return input.findn(_token, pos) == pos
	
	func is_operator() -> bool:
		return _is_operator
	
	func is_inner_class() -> bool:
		return _token == "class"
	
	func is_variable() -> bool:
		return false
	
	func is_token(token_name :String) -> bool:
		return _token == token_name
	
	func _to_string():
		return "{" + _token + "}"


class Operator extends Token:
	func _init(value: String).(value, true) -> void:
		pass

class Variable extends Token:
	var _plain_value
	var _typed_value
	var _type := TYPE_NIL

	func _init(value: String).(value) -> void:
		_type = _scan_type(value)
		_plain_value = value
		_typed_value = _cast_to_type(value, _type)

	func _scan_type(value: String) -> int:
		if value.begins_with("\"") and value.ends_with("\""):
			return TYPE_STRING
		var type := GdObjects.string_to_type(value)
		if type != TYPE_NIL:
			return type
		if value.is_valid_integer():
			return TYPE_INT
		if value.is_valid_float():
			return TYPE_REAL
		if value.is_valid_hex_number():
			return TYPE_INT
		return TYPE_OBJECT

	func _cast_to_type(value :String, type: int):
		match type:
			TYPE_STRING:
				return value#.substr(1, value.length() - 2)
			TYPE_INT:
				return int(value)
			TYPE_REAL:
				return float(value)
		return value

	func is_variable() -> bool:
		return true

	func type() -> int:
		return _type

	func value():
		return _typed_value

	func plain_value():
		return _plain_value

	func _to_string():
		return "{%s:%s}" % [_plain_value, GdObjects.type_as_string(_type)]

class TokenInnerClass extends Token:
	var _clazz_name
	var _content := PoolStringArray()

	static func _strip_leading_spaces(input :String) -> String:
		var characters := input.to_ascii()
		while not characters.empty():
			if characters[0] != 0x20:
				break
			characters.remove(0)
		return characters.get_string_from_ascii()

	static func _consumed_bytes(row :String) -> int:
		return row.replace(" ", "").replace("	", "").length()

	func _init(clazz_name :String).("class") -> void:
		_clazz_name = clazz_name

	func is_class_name(clazz_name :String) -> bool:
		return _clazz_name == clazz_name

	func content() -> PoolStringArray:
		return _content

	func parse(source_rows :PoolStringArray, offset :int) -> void:
		# add class signature
		_content.append(source_rows[offset])
		# parse class content
		for row_index in range(offset+1, source_rows.size()):
			# scan until next non tab
			var source_row := source_rows[row_index]
			var row = _strip_leading_spaces(source_row)
			if row.empty() or row.begins_with("\t") or row.begins_with("#"):
				# fold all line to left by removing leading tabs and spaces
				if source_row.begins_with("\t"):
					source_row.erase(0, 1)
				# refomat invalid empty lines
				if source_row.dedent().empty():
					_content.append("")
				else:
					_content.append(source_row)
				continue
			break
		_consumed += _consumed_bytes(_content.join(""))

func _init():
	_regex_clazz_name = prepare_regex("(class)([a-zA-Z0-9]+)(extends[a-zA-Z]+:)|(class)([a-zA-Z0-9]+)(:)")

func get_token(input :String, current_index) -> Token:
	for t in TOKENS:
		if t.match(input, current_index):
			return t
	return TOKEN_NOT_MATCH

func next_token(input: String, current_index: int) -> Token:
	var token := TOKEN_NOT_MATCH
	for t in TOKENS:
		if t.match(input, current_index):
			token = t
			break
	if token == OPERATOR_SUB:
		token = tokenize_value(input, current_index, token)
	if token == TOKEN_INNER_CLASS:
		token = tokenize_inner_class(input, current_index, token)
	if token == TOKEN_NOT_MATCH:
		return tokenize_value(input, current_index, token)
	return token

func tokenize_value(input: String, current: int, token: Token) -> Token:
	var next := 0
	var current_token = ""
	# test for '--', '+-', '*-', '/-', '%-', or at least '-x'
	var test_for_sign := (token == null or token.is_operator()) and input[current] == "-"
	while current + next < len(input):
		var character := input[current + next] as String
		# if first charater a sign
		# or allowend charset
		# or is a float value
		if (test_for_sign and next==0) \
			or character in ALLOWED_CHARACTERS \
			or (character == "." and current_token.is_valid_integer()):
			current_token += character
			next += 1
			continue
		break
	if current_token != "":
		return Variable.new(current_token)
	return TOKEN_NOT_MATCH

func extract_clazz_name(value :String) -> String:
	var result := _regex_clazz_name.search(value)
	if result == null:
		push_error("Can't extract class name from '%s'" % value)
		return ""
	if result.get_string(2).empty():
		return result.get_string(5)
	else:
		return result.get_string(2)

func tokenize_inner_class(source_code: String, current: int, token: Token) -> Token:
	var clazz_name := extract_clazz_name(source_code.substr(current, 64))
	return TokenInnerClass.new(clazz_name)

func _process_values(left: Token, token_stack: Array, operator: Token) -> Token:
	# precheck
	if left.is_variable() and operator.is_operator():
		var lvalue = left.value()
		var value = null
		var next_token = token_stack.pop_front() as Token

		match operator:
			OPERATOR_ADD:
				value =  lvalue + next_token.value()
			OPERATOR_SUB:
				value =  lvalue - next_token.value()
			OPERATOR_MUL:
				value =  lvalue * next_token.value()
			OPERATOR_DIV:
				value =  lvalue / next_token.value()
			OPERATOR_REMAINDER:
				value =  lvalue & next_token.value()
			_:
				assert(false, "Unsupported operator %s" % operator)
		return Variable.new( str(value))
	return operator

func parse_func_return_type(row: String) -> int:
	var token := parse_return_token(row)
	if token == TOKEN_NOT_MATCH:
		return TYPE_NIL
	return token.type()

func parse_return_token(row: String) -> Token:
	var input := clean_up_row(row)
	var current_index := 0
	var token :Token = null
	var bracket := 0
	while current_index < len(input):
		token = next_token(input, current_index) as Token
		current_index += token._consumed
		if token == TOKEN_BRACKET_OPEN:
			bracket += 1
		if token == TOKEN_BRACKET_CLOSE:
			bracket -= 1
		# function end reached ?
		if bracket == 0 and token == TOKEN_BRACKET_CLOSE:
			token = next_token(input, current_index) as Token
			current_index += token._consumed
			if token == TOKEN_FUNCTION_RETURN_TYPE:
				return next_token(input, current_index) as Token
			else:
				return TOKEN_NOT_MATCH
	return TOKEN_NOT_MATCH

# Parses the argument into a argument signature
# e.g. func foo(arg1 :int, arg2 = 20) -> [arg1, arg2]
func parse_arguments(row: String) -> Array:
	var args := Array()
	var input := clean_up_row(row)
	var current_index := 0
	var token :Token = null
	var bracket := 0
	var next_tokens : = [TOKEN_FUNCTION_DECLARATION]
	while current_index < len(input):
		token = next_token(input, current_index)
		current_index += token._consumed
		if token == TOKEN_BRACKET_OPEN:
			bracket += 1
		if token == TOKEN_BRACKET_CLOSE:
			bracket -= 1
		if not next_tokens.has(token) and not token.is_variable() :
			continue
		# is function
		if token == TOKEN_FUNCTION_DECLARATION:
			token = next_token(input, current_index)
			current_index += token._consumed
			next_tokens = [TOKEN_BRACKET_OPEN, TOKEN_BRACKET_CLOSE]
			continue
		# is argument
		if bracket == 1 and token.is_variable():
			var arg_name = token.plain_value()
			var arg_type = ""
			var arg_value = ""
			# parse type and default value
			while current_index < len(input):
				token = next_token(input, current_index)
				current_index += token._consumed
				match token:
					TOKEN_ARGUMENT_TYPE:
						token = next_token(input, current_index)
						arg_type = token._token
					TOKEN_ARGUMENT_TYPE_ASIGNMENT:
						arg_value = _parse_end_function(input.substr(current_index), true)
						current_index += arg_value.length()
					TOKEN_ARGUMENT_ASIGNMENT:
						arg_value = _parse_end_function(input.substr(current_index), true)
						current_index += arg_value.length()
					TOKEN_BRACKET_OPEN:
						bracket += 1
						# if value a function?
						if bracket > 1:
							# complete the argument value
							var func_begin = input.substr(current_index-TOKEN_BRACKET_OPEN._consumed)
							var func_body = _parse_end_function(func_begin)
							arg_value += func_body
							# fix parse index to end of value
							current_index += func_body.length() - TOKEN_BRACKET_OPEN._consumed - TOKEN_BRACKET_CLOSE._consumed
					TOKEN_BRACKET_CLOSE:
						bracket -= 1
						# end of function
						if bracket == 0:
							break
					TOKEN_ARGUMENT_SEPARATOR:
						if bracket <= 1:
							break
			args.append(GdFunctionArgument.new(arg_name, arg_type, arg_value))
	return args

# Parse an string for an argument with given name <argument_name> and returns the value
# if the argument not found the <default_value> is returned
func parse_argument(row: String, argument_name: String, default_value):
	var input := clean_up_row(row)
	var argument_found := false
	var current_index := 0
	var token :Token = null
	while current_index < len(input):
		token = next_token(input, current_index) as Token
		current_index += token._consumed
		if token == TOKEN_NOT_MATCH:
			push_error("Error on parsing argument '%s'" % row)
		if not argument_found and not token.is_token(argument_name):
			continue
		argument_found = true
		# extract value
		match token:
			TOKEN_ARGUMENT_TYPE_ASIGNMENT:
				token = next_token(input, current_index) as Token
				return token.value()
			TOKEN_ARGUMENT_ASIGNMENT:
				token = next_token(input, current_index) as Token
				return token.value()
	return default_value

# Extracts the full fuzzer signature and collects into a array from the given <row>
# if no fuzzer argument found an empty String is returned
func parse_fuzzers(row: String) -> PoolStringArray:
	var argument_name := Fuzzer.ARGUMENT_FUZZER_INSTANCE
	var input := clean_up_row(row)
	var current_index := 0
	var token :Token = null
	var fuzzers := PoolStringArray()
	while current_index < len(input):
		token = next_token(input, current_index) as Token
		if token == TOKEN_NOT_MATCH:
			push_error("Error on parsing fuzzer '%s'" % row)
		if token in FUZZER_TOKENS:
			var fuzzer := _parse_end_function(input.substr(current_index))
			fuzzers.append(fuzzer)
			current_index += fuzzer.length()
			continue
		current_index += token._consumed
	return fuzzers


func _parse_end_function(input: String, remove_trailing_char := false) -> String:
	# find end of function
	var current_index := 0
	var bracket_count := 0
	var is_array := false
	var end_of_func = false

	while current_index < len(input) and not end_of_func:
		var character = input[current_index]
		match character:
			# count if inside an array
			"[": is_array = true
			"]": is_array = false
			# count if inside a function
			"(": bracket_count += 1
			")":
				bracket_count -= 1
				if bracket_count <= 0:
					end_of_func = true
			",":
				if bracket_count == 0 and not is_array:
					end_of_func = true
		current_index += 1
	if remove_trailing_char:
		# check if the parsed value ends with comma or end of doubled breaked
		# `<value>,` or `<function>())`
		var trailing_char := input[current_index-1]
		if trailing_char == ',' or (bracket_count < 0 and trailing_char == ')'):
			return input.substr(0, current_index-1)
	return input.substr(0, current_index)

func extract_inner_class(source_rows: PoolStringArray, clazz_name :String) -> PoolStringArray:
	for row_index in source_rows.size():
		var input := clean_up_row(source_rows[row_index])
		var token := next_token(input, 0)
		if token.is_inner_class():
			if token.is_class_name(clazz_name):
				token.parse(source_rows, row_index)
				return token.content()
	return PoolStringArray()

func extract_source_code(script_path :PoolStringArray) -> PoolStringArray:
	if script_path.empty():
		push_error("Invalid script path '%s'" % script_path)
		return PoolStringArray()
	#load the source code
	var resource_path := script_path[0]
	var script :GDScript = load(resource_path)
	var source_code := load_source_code(script, script_path)
	var base_script := script.get_base_script()
	if base_script:
		_base_clazz = GdObjects.extract_class_name_from_class_path([base_script.resource_path])
		source_code += load_source_code(base_script, script_path)
	return source_code

func load_source_code(script :GDScript, script_path :PoolStringArray) -> PoolStringArray:
	var map := script.get_script_constant_map()
	for key in map.keys():
		var value = map.get(key)
		if value is GDScript:
			var class_path := GdObjects.extract_class_path(value)
			if class_path.size() > 1:
				_scanned_inner_classes.append(class_path[1])

	var source_code := to_unix_format(script.source_code)
	var source_rows := source_code.split("\n")
	# extract all inner class names
	# want to extract an inner class?
	if script_path.size() > 1:
		var inner_clazz = script_path[1]
		source_rows = extract_inner_class(source_rows, inner_clazz)
	return PoolStringArray(source_rows)

func get_class_name(script :GDScript) -> String:
	var source_code := to_unix_format(script.source_code)
	var source_rows := source_code.split("\n")
	
	for index in min(10, source_rows.size()):
		var input = clean_up_row(source_rows[index])
		var token := next_token(input, 0)
		if token == TOKEN_CLASS_NAME:
			token = next_token(input, token._consumed)
			return token.value()
	# if no class_name found extract from file name
	return GdObjects.to_pascal_case(script.resource_path.get_basename().get_file())

func parse_func_name(row :String) -> String:
	var input = clean_up_row(row)
	var token := next_token(input, 0)
	if token != TOKEN_FUNCTION_STATIC_DECLARATION and token != TOKEN_FUNCTION_DECLARATION:
		return ""
	var next := next_token(input, token._consumed)
	return next._token

func parse_functions(rows :PoolStringArray, clazz_name :String, clazz_path :PoolStringArray) -> Array:
	var func_descriptors := Array()
	for row in rows:
		# step over inner class functions
		if row.begins_with("\t"):
			continue
		var input = clean_up_row(row)
		var token := next_token(input, 0)
		if token == TOKEN_FUNCTION_STATIC_DECLARATION or token == TOKEN_FUNCTION_DECLARATION:
			func_descriptors.append(parse_func_description(row, clazz_name, clazz_path))
	return func_descriptors

func parse_func_description(func_signature :String, clazz_name :String, clazz_path :PoolStringArray) -> GdFunctionDescriptor:
	var name =  parse_func_name(func_signature)
	var return_type :int
	var return_clazz := ""
	var token := parse_return_token(func_signature)
	if token == TOKEN_NOT_MATCH:
		return_type = TYPE_NIL
	else:
		return_type = token.type()
		if token.type() == TYPE_OBJECT:
			return_clazz = _patch_inner_class_names(token.value(), clazz_name)

	return GdFunctionDescriptor.new(
		name,
		is_virtual_func(clazz_name, clazz_path, name),
		is_static_func(func_signature),
		false,
		return_type,
		return_clazz,
		parse_arguments(func_signature)
	)

# caches already parsed classes for virtual functions
# key: <clazz_name> value: a Array of virtual function names
var _virtual_func_cache := Dictionary()

func is_virtual_func(clazz_name :String, clazz_path :PoolStringArray, func_name :String) -> bool:
	if _virtual_func_cache.has(clazz_name):
		return _virtual_func_cache[clazz_name].has(func_name)

	var virtual_functions := Array()
	var method_list := GdObjects.extract_class_functions(clazz_name, clazz_path)
	for method_descriptor in method_list:
		var is_virtual_function :bool = method_descriptor["flags"] & METHOD_FLAG_VIRTUAL
		if is_virtual_function:
			virtual_functions.append(method_descriptor["name"])
	_virtual_func_cache[clazz_name] = virtual_functions
	return _virtual_func_cache[clazz_name].has(func_name)

func is_static_func(func_signature :String) -> bool:
	var input := clean_up_row(func_signature)
	var token := next_token(input, 0)
	return token == TOKEN_FUNCTION_STATIC_DECLARATION

func is_inner_class(clazz_path :PoolStringArray) -> bool:
	return clazz_path.size() > 1

func _patch_inner_class_names(value :String, clazz_name :String) -> String:
	var patch := value
	var base_clazz := clazz_name.split(".")[0]

	for inner_clazz_name in _scanned_inner_classes:
		var full_inner_clazz_path = base_clazz + "." + inner_clazz_name
		patch = patch.replace(inner_clazz_name, full_inner_clazz_path)
	return patch


func extract_functions(script :GDScript, clazz_name :String, clazz_path :PoolStringArray) -> Array:
	var source_code := load_source_code(script, clazz_path)
	return parse_functions(source_code, clazz_name, clazz_path)

func parse(clazz_name :String, clazz_path :PoolStringArray) -> Result:

	if clazz_path.empty():
		return Result.error("Invalid script path '%s'" % clazz_path)

	var is_inner_class := is_inner_class(clazz_path)

	var script :GDScript = load(clazz_path[0])
	var function_descriptors := extract_functions(script, clazz_name, clazz_path)
	var gd_class := GdClassDescriptor.new(clazz_name, is_inner_class, function_descriptors)

	# iterate over class dependencies
	script = script.get_base_script()
	while script != null:
		clazz_name = GdObjects.extract_class_name_from_class_path([script.resource_path])
		function_descriptors = extract_functions(script, clazz_name, clazz_path)
		gd_class.set_parent_clazz(GdClassDescriptor.new(clazz_name, is_inner_class, function_descriptors))
		script = script.get_base_script()

	return Result.success(gd_class)

class_name GdAssertMessages
extends Resource

const WARN_COLOR = "#EFF883"
const ERROR_COLOR = "#CD5C5C"
const VALUE_COLOR = "#1E90FF"


static func _warning(error:String) -> String:
	return "[color=%s]%s[/color]" % [WARN_COLOR, error]

static func _error(error:String) -> String:
	return "[color=%s]%s[/color]" % [ERROR_COLOR, error]

static func _nerror(number) -> String:
	match typeof(number):
		TYPE_INT:
			return "[color=%s]%d[/color]" % [ERROR_COLOR, number]
		TYPE_REAL:
			return "[color=%s]%f[/color]" % [ERROR_COLOR, number]
		_:
			return "[color=%s]%s[/color]" % [ERROR_COLOR, str(number)]

static func _current(value, delimiter ="\n") -> String:
	match typeof(value):
		TYPE_STRING:
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, colorDiff(value)]
		TYPE_INT:
			return "'[color=%s]%d[/color]'" % [VALUE_COLOR, value]
		TYPE_REAL:
			return "'[color=%s]%f[/color]'" % [VALUE_COLOR, value]
		TYPE_OBJECT:
			return "[color=%s]<%s>[/color]" % [VALUE_COLOR, value.get_class()]
		_:
			if GdObjects.is_array_type(value):
				return "[color=%s]%s[/color]" % [VALUE_COLOR, GdObjects.array_to_string(value, delimiter)]
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, value]

static func _expected(value, delimiter ="\n") -> String:
	match typeof(value):
		TYPE_STRING:
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, colorDiff(value)]
		TYPE_INT:
			return "'[color=%s]%d[/color]'" % [VALUE_COLOR, value]
		TYPE_REAL:
			return "'[color=%s]%f[/color]'" % [VALUE_COLOR, value]
		TYPE_OBJECT:
			return "[color=%s]<%s>[/color]" % [VALUE_COLOR, value.get_class()]
		_:
			if GdObjects.is_array_type(value):
				return "[color=%s]%s[/color]" % [VALUE_COLOR, GdObjects.array_to_string(value, delimiter)]
			return "'[color=%s]%s[/color]'" % [VALUE_COLOR, value]

static func orphan_detected_on_suite_setup(count :int):
	return "%s\n Detected <%d> orphan nodes during test suite setup stage! [b]Check before() and after()![/b]" % [
		_warning("WARNING:"), count]

static func orphan_detected_on_test_setup(count :int):
	return "%s\n Detected <%d> orphan nodes during test setup! [b]Check before_test() and after_test()![/b]" % [
		_warning("WARNING:"), count]

static func orphan_detected_on_test(count :int):
	return "%s\n Detected <%d> orphan nodes during test execution!" % [
		_warning("WARNING:"), count]
	
static func fuzzer_interuped(iterations: int, error: String) -> String:
	return "%s %s %s\n %s" % [
		_error("Found an error after"), 
		_current(iterations + 1), 
		_error("test iterations"), 
		error]

static func error_not_implemented() -> String:
	return _error("Test not implemented!")

static func error_is_null(current) -> String:
	return "%s %s but was %s" % [_error("Expecting:"), _expected(null), _current(current)]

static func error_is_not_null() -> String:
	return "%s %s" % [_error("Expecting: not to be"), _current(null)]

static func error_equal(current, expected) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting:"), _expected(expected), _current(current)]

static func error_not_equal(current, expected) -> String:
	return "%s\n %s\n not equal to\n %s" % [_error("Expecting:"), _expected(expected), _current(current)]

static func error_is_empty(current) -> String:
	return "%s\n must be empty but was\n %s" % [_error("Expecting:"), _current(current)]

static func error_is_not_empty() -> String:
	return "%s\n must not be empty" % [_error("Expecting:")]

static func error_is_same(current, expected) -> String:
	return "%s\n %s\n to refer to the same object\n %s" % [_error("Expecting:"), \
			_expected(expected), \
			_current(current)]

static func error_not_same(current, expected) -> String:
	return "%s %s" % [_error("Expecting: not same"), _expected(expected)]

static func error_not_same_error(current, expected) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting error message:"), _expected(expected), _current(current)]

static func error_is_instanceof(current: Result, expected :Result) -> String:
	return "%s\n %s\n But it was %s" % [_error("Expected instance of:"),\
		_expected(expected.or_else(null)), _current(current.or_else(null))]

# -- Boolean Assert specific messages -----------------------------------------------------
static func error_is_true() -> String:
	return "%s %s but is %s" % [_error("Expecting:"), _expected(true), _current(false)]

static func error_is_false() -> String:
	return "%s %s but is %s" % [_error("Expecting:"), _expected(false), _current(true)]



# - Integer/Float Assert specific messages -----------------------------------------------------

static func error_is_even(current) -> String:
	return "%s\n %s must be even" % [_error("Expecting:"), _current(current)]

static func error_is_odd(current) -> String:
	return "%s\n %s must be odd" % [_error("Expecting:"), _current(current)]

static func error_is_negative(current) -> String:
	return "%s\n %s be negative" % [_error("Expecting:"), _current(current)]

static func error_is_not_negative(current) -> String:
	return "%s\n %s be not negative" % [_error("Expecting:"), _current(current)]

static func error_is_zero(current) -> String:
	return "%s\n equal to 0 but is %s" % [_error("Expecting:"), _current(current)]

static func error_is_not_zero() -> String:
	return "%s\n not equal to 0" % [_error("Expecting:")]

static func error_is_value(operation, current, expected, expected2=null) -> String:
	match operation:
		Comparator.EQUAL:
			return "%s\n %s but was '%s'" % [_error("Expecting:"), _expected(expected), _nerror(current)]
		Comparator.LESS_THAN:
			return "%s\n %s but was '%s'" % [_error("Expecting to be less than:"), _expected(expected), _nerror(current)]
		Comparator.LESS_EQUAL:
			return "%s\n %s but was '%s'" % [_error("Expecting to be less than or equal:"), _expected(expected), _nerror(current)]
		Comparator.GREATER_THAN:
			return "%s\n %s but was '%s'" % [_error("Expecting to be greater than:"), _expected(expected), _nerror(current)]
		Comparator.GREATER_EQUAL:
			return "%s\n %s but was '%s'" % [_error("Expecting to be greater than or equal:"), _expected(expected), _nerror(current)]
		Comparator.BETWEEN_EQUAL:
			return "%s\n %s\n in range between\n %s <> %s" % [_error("Expecting:"), _current(current), _expected(expected), _expected(expected2)]
		Comparator.NOT_BETWEEN_EQUAL:
			return "%s\n %s\n not in range between\n %s <> %s" % [_error("Expecting:"), _current(current), _expected(expected), _expected(expected2)]
	return "TODO create expected message"

static func error_is_in(current, expected :Array) -> String:
	return "%s\n %s\n is in\n %s" % [_error("Expecting:"), _current(current), _expected(str(expected))]

static func error_is_not_in(current, expected :Array) -> String:
	return "%s\n %s\n is not in\n %s" % [_error("Expecting:"), _current(current), _expected(str(expected))]


# - StringAssert ---------------------------------------------------------------------------------
static func error_equal_ignoring_case(current, expected) -> String:
	return "%s\n %s\n but was\n %s (ignoring case)" % [_error("Expecting:"), _expected(expected), _current(current)]

static func error_contains(current, expected) -> String:
	return "%s\n %s\n do contains\n %s" % [_error("Expecting:"), _current(current), _expected(expected)]

static func error_not_contains(current, expected) -> String:
	return "%s\n %s\n not do contain\n %s" % [_error("Expecting:"), _current(current), _expected(expected)]

static func error_contains_ignoring_case(current, expected) -> String:
	return "%s\n %s\n contains\n %s\n (ignoring case)" % [_error("Expecting:"), _current(current), _expected(expected)]

static func error_not_contains_ignoring_case(current, expected) -> String:
	return "%s\n %s\n not do contains\n %s\n (ignoring case)" % [_error("Expecting:"), _current(current), _expected(expected)]

static func error_starts_with(current, expected) -> String:
	return "%s\n %s\n to start with\n %s" % [_error("Expecting:"), _current(current), _expected(expected)]

static func error_ends_with(current, expected) -> String:
	return "%s\n %s\n to end with\n %s" % [_error("Expecting:"), _current(current), _expected(expected)]

static func error_has_length(current, expected: int, compare_operator) -> String:
	match compare_operator:
		Comparator.EQUAL:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size:"), _expected(expected), _nerror(current.length()), _current(current)]
		Comparator.LESS_THAN:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be less than:"), _expected(expected), _nerror(current.length()), _current(current)]
		Comparator.LESS_EQUAL:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be less than or equal:"), _expected(expected), _nerror(current.length()), _current(current)]
		Comparator.GREATER_THAN:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be greater than:"), _expected(expected), _nerror(current.length()), _current(current)]
		Comparator.GREATER_EQUAL:
			return "%s\n %s but was '%s' in\n %s" % [_error("Expecting size to be greater than or equal:"), _expected(expected), _nerror(current.length()), _current(current)]
	return "TODO create expected message"



# - ArrayAssert specific messgaes ---------------------------------------------------
static func error_arr_contains(current :Array, expected :Array, not_expect :Array, not_found :Array) -> String:
	var error := "%s\n %s\n do contains (in any order)\n %s" % [_error("Expecting contains elements:"), _current(current, ", "), _expected(expected, ", ")]
	if not not_expect.empty():
		error += "\nbut some elements where not expected:\n %s" % _expected(not_expect, ", ")
	if not not_found.empty():
		var prefix = "but" if not_expect.empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _expected(not_found, ", ")]
	return error

static func error_arr_contains_exactly(current :Array, expected :Array, not_expect :Array, not_found :Array) -> String:
	if not_expect.empty() and not_found.empty():
		var diff := _find_first_diff(current, expected)
		return "%s\n %s\n do contains (in same order)\n %s\n but has different order %s"  % [_error("Expecting contains exactly elements:"), _current(current, ", "), _expected(expected, ", "), diff]
	
	var error := "%s\n %s\n do contains (in same order)\n %s" % [_error("Expecting contains exactly elements:"), _current(current, ", "), _expected(expected, ", ")]
	if not not_expect.empty():
		error += "\nbut some elements where not expected:\n %s" % _expected(not_expect, ", ")
	if not not_found.empty():
		var prefix = "but" if not_expect.empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _expected(not_found, ", ")]
	return error

static func error_arr_contains_exactly_in_any_order(current :Array, expected :Array, not_expect :Array, not_found :Array) -> String:
	var error := "%s\n %s\n do contains exactly (in any order)\n %s" % [_error("Expecting contains exactly elements:"), _current(current, ", "), _expected(expected, ", ")]
	if not not_expect.empty():
		error += "\nbut some elements where not expected:\n %s" % _expected(not_expect, ", ")
	if not not_found.empty():
		var prefix = "but" if not_expect.empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _expected(not_found, ", ")]
	return error

# - DictionaryAssert specific messages ----------------------------------------------
static func error_contains_keys(current :Array, expected :Array, keys_not_found :Array) -> String:
	return "%s\n %s\n to contains:\n %s\n but can't find key's:\n %s" % [_error("Expecting keys:"), _current(current, ", "), _current(expected, ", "), _expected(keys_not_found, ", ")]

static func error_not_contains_keys(current :Array, expected :Array, keys_not_found :Array) -> String:
	return "%s\n %s\n do not contains:\n %s\n but contains key's:\n %s" % [_error("Expecting keys:"), _current(current, ", "), _current(expected, ", "), _expected(keys_not_found, ", ")]

static func error_contains_key_value(key, value, current_value) -> String:
	return "%s\n %s : %s\n but contains\n %s : %s" % [_error("Expecting key and value:"), _expected(key), _expected(value), _current(key), _current(current_value)]


# - ResultAssert specific errors ----------------------------------------------------
static func error_result_is_empty(current :Result) -> String:
	return _result_error_message(current, Result.EMPTY)

static func error_result_is_success(current :Result) -> String:
	return _result_error_message(current, Result.SUCCESS)

static func error_result_is_warning(current :Result) -> String:
	return _result_error_message(current, Result.WARN)

static func error_result_is_error(current :Result) -> String:
	return _result_error_message(current, Result.ERROR)

static func error_result_has_message(current :String, expected :String) -> String:
	return "%s\n %s\n but was\n %s." % [_error("Expecting:"), _expected(expected), _current(current)]

static func error_result_has_message_on_success(expected :String) -> String:
	return "%s\n %s\n but the Result is a success." % [_error("Expecting:"), _expected(expected)]

static func error_result_is_value(current, expected) -> String:
	return "%s\n %s\n but was\n %s." % [_error("Expecting to contain same value:"), _expected(expected), _current(current)]

static func _result_error_message(current :Result, expected_type :int) -> String:
	if current.is_success():
		return _error("Expecting the result must be a %s but was SUCCESS." % result_type(expected_type))
	var error = "Expecting the result must be a %s but was %s:" % [result_type(expected_type), result_type(current._state)]
	return "%s\n %s" % [_error(error), _current(result_message(current))]

static func error_interrupted(func_name :String, expected, elapsed :String) -> String:
	func_name = humanized(func_name)
	if expected == null:
		return "%s %s but timed out after %s" % [_error("Expected:"), func_name, elapsed]
	return "%s %s %s but timed out after %s" % [_error("Expected:"), func_name, _current(expected), elapsed]

static func error_wait_signal(signal_name :String, args :Array, elapsed :String) -> String:
	if args.empty():
		return "%s %s but timed out after %s" % [_error("Expecting emit signal:"), _current(signal_name + "()"), elapsed]
	return "%s %s but timed out after %s" % [_error("Expecting emit signal:"), _current(signal_name + "(" + str(args) + ")"), elapsed]

static func error_signal_emitted(signal_name :String, args :Array, elapsed :String) -> String:
	if args.empty():
		return "%s %s but is emitted after %s" % [_error("Expecting do not emit signal:"), _current(signal_name + "()"), elapsed]
	return "%s %s but is emitted after %s" % [_error("Expecting do not emit signal:"), _current(signal_name + "(" + str(args) + ")"), elapsed]


static func result_type(type :int) -> String:
	match type:
		Result.SUCCESS: return "SUCCESS"
		Result.WARN: return "WARNING"
		Result.ERROR: return "ERROR"
		Result.EMPTY: return "EMPTY"
	return "UNKNOWN"

static func result_message(result :Result) -> String:
	match result._state:
		Result.SUCCESS: return ""
		Result.WARN: return result.warn_message()
		Result.ERROR: return result.error_message()
		Result.EMPTY: return ""
	return "UNKNOWN"
# -----------------------------------------------------------------------------------

# - Spy|Mock specific errors ----------------------------------------------------
static func error_no_more_interactions(summary :Dictionary) -> String:
	var interactions := PoolStringArray()
	for args in summary.keys():
		var times :int = summary[args]
		interactions.append(_format_arguments(args, times))
	return "%s\n%s\n%s" % [_error("Expecting no more interacions!"), _error("But found interactions on:"), interactions.join("\n")] 

static func error_validate_interactions(current_interactions :Dictionary, expected_interactions :Dictionary) -> String:
	var interactions := PoolStringArray()
	for args in current_interactions.keys():
		var times :int = current_interactions[args]
		interactions.append(_format_arguments(args, times))
	var expected_interaction := _format_arguments(expected_interactions.keys()[0], expected_interactions.values()[0])
	return "%s\n%s\n%s\n%s" % [_error("Expecting interacion on:"), expected_interaction, _error("But found interactions on:"), interactions.join("\n")]

static func _format_arguments(args :Array, times :int) -> String:
	var fname :String = args[0]
	var fargs := args.slice(1, -1) as Array
	var typed_args := _to_typed_args(fargs)
	var fsignature := _current("%s(%s)" % [fname, typed_args.join(", ")])
	return "	%s	%d time's" % [fsignature, times]

static func _to_typed_args(args :Array) -> PoolStringArray:
	var typed := PoolStringArray()
	for arg in args:
		typed.append( str(arg) + " :" + GdObjects.type_as_string(typeof(arg)))
	return typed

static func _find_first_diff( left :Array, right :Array) -> String:
	for index in left.size():
		var l = left[index]
		var r = "<no entry>" if index >= right.size() else right[index]
		if not GdObjects.equals(l, r):
			return "at position %s\n %s vs %s" % [_current(index), _current(l), _expected(r)]
	return ""

static func error_has_size(current: int, expected: int) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting size:"), _expected(expected), _current(current)]

static func error_contains_exactly(current: Array, expected: Array) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting exactly equal:"), _expected(expected), _current(current)]

const SUB_COLOR :=  Color.red
const ADD_COLOR :=  Color.green
static func colorDiff(value :String) -> String:
	var result = PoolByteArray()
	var characters := value.to_ascii()
	var index = 0
	var missing_chars := PoolByteArray()
	var additional_chars := PoolByteArray()
	
	while index < characters.size():
		var character = characters[index]
		match character:
			GdObjects.DIV_ADD:
				index += 1
				additional_chars.append(characters[index])
			GdObjects.DIV_SUB:
				index += 1
				missing_chars.append(characters[index])
			_:
				result.append_array(format_chars(missing_chars, SUB_COLOR))
				result.append_array(format_chars(additional_chars, ADD_COLOR))
				missing_chars = PoolByteArray()
				additional_chars = PoolByteArray()
				result.append(character)
		index += 1
	
	result.append_array(format_chars(missing_chars, SUB_COLOR))
	result.append_array(format_chars(additional_chars, ADD_COLOR))
	return result.get_string_from_ascii()


static func format_chars(characters :PoolByteArray, type :Color) -> PoolByteArray:
	var result := PoolByteArray()
	if characters.size() == 0:
		return result
	if characters.size() == 1 and characters[0] == 10:
		if type == ADD_COLOR:
			result.append_array(("[bg color=#%s]\n<--empty line-->[/bg]" % [type.to_html()]).to_utf8())
		else:
			result.append_array(("[bg color=#%s][s]\n<--empty line-->[/s][/bg]" % type.to_html()).to_utf8())
		return result
	if type == ADD_COLOR:
		result.append_array(("[bg color=#%s]%s[/bg]" % [type.to_html(), characters.get_string_from_ascii()]).to_utf8())
	else:
		result.append_array(("[bg color=#%s]%s[/bg]" % [type.to_html(), characters.get_string_from_ascii()]).to_utf8())
	return result

static func humanized(value :String) -> String:
	return value.replace("_", " ")

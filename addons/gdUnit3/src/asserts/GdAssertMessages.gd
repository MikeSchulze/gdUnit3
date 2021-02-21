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

static func orphan_detected_on_before(count :int):
	return "%s\n Detected <%d> orphan nodes on stage [b]before()[/b]!" % [
		_warning("WARNING:"), count]

static func orphan_detected_on_before_test(count :int):
	return "%s\n Detected <%d> orphan nodes on stage [b]before_test()[/b]!" % [
		_warning("WARNING:"), count]

static func orphan_detected_on_test(count :int):
	return "%s\n Detected <%d> orphan nodes!" % [
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

static func error_is_in_range(current, from, to) -> String:
	return "%s\n %s\n in range between\n %s <> %s" % [_error("Expecting:"), _current(current), _expected(from), _expected(to)]

static func error_is_value(current, expected, compare_operator) -> String:
	match compare_operator:
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
	var error := "%s\n %s\n do contains\n %s" % [_error("Expecting:"), _current(current), _expected(expected)]
	if not not_expect.empty():
		error += "\nbut some elements where not expected:\n %s" % _expected(not_expect)
	if not not_found.empty():
		var prefix = "but" if not_expect.empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _expected(not_found)]
	return error

# - DictionaryAssert specific messages ----------------------------------------------
static func error_contains_keys(current :Array, expected :Array, keys_not_found :Array) -> String:
	return "%s\n %s\n to contains:\n %s\n but can't find key's:\n %s" % [_error("Expecting keys:"), _current(current, ", "), _current(expected, ", "), _expected(keys_not_found, ", ")]

static func error_not_contains_keys(current :Array, expected :Array, keys_not_found :Array) -> String:
	return "%s\n %s\n do not contains:\n %s\n but contains key's:\n %s" % [_error("Expecting keys:"), _current(current, ", "), _current(expected, ", "), _expected(keys_not_found, ", ")]

static func error_contains_key_value(key, value, current_value) -> String:
	return "%s\n %s : %s\n but contains\n %s : %s" % [_error("Expecting key and value:"), _expected(key), _expected(value), _current(key), _current(current_value)]


# - ResultAssert specific errors ----------------------------------------------------
static func error_result_is_success() -> String:
	return _error("Expecting: The result must be a success.")

static func error_result_is_warning() -> String:
	return _error("Expecting: The result must be a warning.")

static func error_result_is_error() -> String:
	return _error("Expecting: The result must be a error.")

static func error_result_has_message(current :String, expected :String) -> String:
	return "%s\n %s\n but was\n %s." % [_error("Expecting:"), _expected(expected), _current(current)]

static func error_result_has_message_on_success(expected :String) -> String:
	return "%s\n %s\n but the Result is a success." % [_error("Expecting:"), _expected(expected)]

static func error_result_is_value(current, expected) -> String:
	return "%s\n %s\n but was\n %s." % [_error("Expecting to contain same value:"), _expected(expected), _current(current)]
# -----------------------------------------------------------------------------------

static func _find_first_diff( left :Array, right :Array) -> String:
	for index in left.size():
		var l = left[index]
		var r = "<no entry>" if index >= right.size() else right[index]
		if not GdObjects.equals(l, r):
			return "at position %s\n %s vs %s" % [_current(index), _current(l), _expected(r)]
	return ""

static func error_arr_contains_exactly(current :Array, expected :Array, not_expect :Array, not_found :Array) -> String:
	if not_expect.empty() and not_found.empty():
		var diff := _find_first_diff(current, expected)
		return "%s\n %s\n %s\n but has different order %s"  % [_error("Expecting to have same elements and in same order:"), _current(current), _expected(expected), diff]
	
	var error := "%s\n %s\n do contains (in same order)\n %s" % [_error("Expecting:"), _current(current), _expected(expected)]
	if not not_expect.empty():
		error += "\nbut some elements where not expected:\n %s" % _expected(not_expect)
	if not not_found.empty():
		var prefix = "but" if not_expect.empty() else "and"
		error += "\n%s could not find elements:\n %s" % [prefix, _expected(not_found)]
	return error




static func error_has_size(current: int, expected: int) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting size:"), _expected(expected), _current(current)]

static func error_contains_exactly(current: Array, expected: Array) -> String:
	return "%s\n %s\n but was\n %s" % [_error("Expecting exactly equal:"), _expected(expected), _current(current)]

const SUB_COLOR :=  Color.red
const ADD_COLOR :=  Color.green
static func colorDiff(value:String) -> String:
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
			result.append_array(("[color=#%s]\n<--empty line-->[/color]" % [type.to_html()]).to_utf8())
		else:
			result.append_array(("[color=#%s][s]\n<--empty line-->[/s][/color]" % type.to_html()).to_utf8())
		return result
	if type == ADD_COLOR:
		result.append_array(("[color=#%s]%s[/color]" % [type.to_html(), characters.get_string_from_ascii()]).to_utf8())
	else:
		result.append_array(("[color=#%s][s]%s[/s][/color]" % [type.to_html(), characters.get_string_from_ascii()]).to_utf8())
	return result

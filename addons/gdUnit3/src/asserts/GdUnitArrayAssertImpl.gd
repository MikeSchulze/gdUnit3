class_name GdUnitArrayAssertImpl
extends GdUnitArrayAssert

var _base :GdUnitAssert
var _extract :FuncRef = null

func _init(current, expect_result: int):
	_base = GdUnitAssertImpl.new(current, expect_result)
	if current != null and not GdObjects.is_array_type(current):
		report_error("GdUnitArrayAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __current() -> Array:
	return Array(_base._current)

func __expected(expected) -> Array:
	return Array(expected)

func report_success() -> GdUnitArrayAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitArrayAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_error_message(expected: String) -> GdUnitArrayAssert:
	_base.has_error_message(expected)
	return self

func starts_with_error_message(expected: String) -> GdUnitArrayAssert:
	_base.starts_with_error_message(expected)
	return self

func as_error_message(message :String) -> GdUnitArrayAssert:
	_base.as_error_message(message)
	return self

func with_error_info(message :String) -> GdUnitArrayAssert:
	_base.with_error_info(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

func is_null() -> GdUnitArrayAssert:
	_base.is_null()
	return self

func is_not_null() -> GdUnitArrayAssert:
	_base.is_not_null()
	return self

# Verifies that the current String is equal to the given one.
func is_equal(expected) -> GdUnitArrayAssert:
	var current_ := __current()
	var expected_ := __expected(expected)
	if not GdObjects.equals(current_, expected_):
		var c := GdObjects.array_to_string(current_, ", ")
		var e := GdObjects.array_to_string(expected_, ", ")
		var diff := GdObjects.string_diff(c, e)
		return report_error(GdAssertMessages.error_equal(diff[1], diff[0]))
	return report_success()

# Verifies that the current Array is equal to the given one, ignoring case considerations.
func is_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	var current_ := __current()
	var expected_ := __expected(expected)
	if not GdObjects.equals(current_, expected_, true):
		var c := GdObjects.array_to_string(current_, ", ")
		var e := GdObjects.array_to_string(expected_, ", ")
		var diff := GdObjects.string_diff(c, e)
		return report_error(GdAssertMessages.error_equal(diff[1], diff[0]))
	return report_success()

func is_not_equal(expected) -> GdUnitArrayAssert:
	var current_ := __current()
	var expected_ := __expected(expected)
	if GdObjects.equals(current_, expected_):
		return report_error(GdAssertMessages.error_not_equal(current_, expected_))
	return report_success()

func is_not_equal_ignoring_case(expected) -> GdUnitArrayAssert:
	var current_ := __current()
	var expected_ := __expected(expected)
	if GdObjects.equals(current_, expected_, true):
		return report_error(GdAssertMessages.error_not_equal(current_, expected_))
	return report_success()

# Verifies that the current Array is empty, it has a size of 0.
func is_empty() -> GdUnitArrayAssert:
	var current_ := __current()
	if current_.size() > 0:
		return report_error(GdAssertMessages.error_is_empty(current_))
	return report_success()

# Verifies that the current Array is not empty, it has a size of minimum 1.
func is_not_empty() -> GdUnitArrayAssert:
	var current_ := __current()
	if current_.size() == 0:
		return report_error(GdAssertMessages.error_is_not_empty())
	return report_success()

# Verifies that the current Array has a size of given value.
func has_size(expected: int) -> GdUnitArrayAssert:
	var current_ := __current()
	if current_.size() != expected:
		return report_error(GdAssertMessages.error_has_size(current_.size(), expected))
	return report_success()

func array_div(left :Array, right :Array, same_order := false) -> Array:
	var not_expect := left.duplicate(true)
	var not_found := right.duplicate(true)
	
	for index_c in left.size():
		var c = left[index_c]
		for index_e in right.size():
			var e = right[index_e]
			if GdObjects.equals(c, e):
				not_expect.erase(e)
				not_found.erase(c)
				break
	return [not_expect, not_found]

# Verifies that the current Array contains the given values, in any order.
func contains(expected) -> GdUnitArrayAssert:
	var current_ := __current()
	var expected_ := __expected(expected)
	var diffs := array_div(current_, expected_)
	var not_expect := diffs[0] as Array
	var not_found := diffs[1] as Array
	if not not_found.empty():
		return report_error(GdAssertMessages.error_arr_contains(current_, expected_, [], not_found))
	return report_success()

# Verifies that the current Array contains only the given values and nothing else, in order.
func contains_exactly(expected) -> GdUnitArrayAssert:
	var current_ := __current()
	var expected_ := __expected(expected)
	# has same content in same order
	if GdObjects.equals(current_, expected_):
		return report_success()
	# check has same elements but in different order

	if GdObjects.equals_sorted(current_, expected_):
		return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected_, [], []))
	# find the difference
	var diffs := array_div(current_, expected_, true)
	var not_expect := diffs[0] as Array
	var not_found := diffs[1] as Array
	return report_error(GdAssertMessages.error_arr_contains_exactly(current_, expected_, not_expect, not_found))


func is_same(expected) -> GdUnitAssert:
	_base.is_same(expected)
	return self

func is_not_same(expected) -> GdUnitAssert:
	_base.is_not_same(expected)
	return self

func is_instanceof(expected) -> GdUnitAssert:
	_base.is_instanceof(expected)
	return self

#-------------------------------------------------------------------------------






# --------------------------------------------------------------------------------------
# TODO convert to new API
# saved func
var _extract_func_name:String = ""
func _extract(func_name:String) -> GdUnitAssert:
	#_extract_func_name = func_name
	#var extract = funcref(__current[0], func_name)
	#if not extract.is_valid():
	#	_extract_func_name = ""
	#	GdAssertReports.report_error("exctract function name faild! '" + func_name + "' not exists", self, get_stack())
	return self


# extracts the value by function name
func extract(func_name :String) -> GdUnitArrayAssert:
	var current_ = __current()[0]
	_extract = funcref(current_, func_name)
	if not _extract.is_valid():
		return report_error("exctract function name faild! '" + func_name + "' not exists")
		
	# switch to extracted assert type
	for method_signature in current_.get_method_list():
		var flags :int = method_signature["flags"]
		var funcName :String = method_signature["name"]
		if flags == METHOD_FLAG_FROM_SCRIPT|METHOD_FLAGS_DEFAULT and funcName == func_name:
			var return_desc :Dictionary = method_signature["return"]
			var return_type :int = return_desc["type"]
			#GdUnitAssertImpl.assert_that(_current)
			# issue https://github.com/godotengine/godot/issues/33624
			# can't switch by retrun type
	return self

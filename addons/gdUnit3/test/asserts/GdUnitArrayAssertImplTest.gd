# GdUnit generated TestSuite
class_name GdUnitArrayAssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitArrayAssertImpl.gd'

func test_is_null():
	assert_array(null).is_null()
	# should fail because the array not null
	assert_array([], GdUnitAssert.EXPECT_FAIL) \
		.is_null()\
		.has_error_message("Expecting: 'Null' but was empty")

func test_is_not_null():
	assert_array([]).is_not_null()
	# should fail because the array is null
	assert_array(null, GdUnitAssert.EXPECT_FAIL) \
		.is_not_null()\
		.has_error_message("Expecting: not to be 'Null'")

func test_is_equal():
	assert_array([1, 2, 3, 4, 2, 5]).is_equal([1, 2, 3, 4, 2, 5])
	# should fail because the array not contains same elements and has diff size
	assert_array([1, 2, 4, 5], GdUnitAssert.EXPECT_FAIL) \
		.is_equal([1, 2, 3, 4, 2, 5])

func test_is_equal_ignoring_case():
	assert_array(["this", "is", "a", "message"]).is_equal_ignoring_case(["This", "is", "a", "Message"])
	# should fail because the array not contains same elements
	assert_array(["this", "is", "a", "message"], GdUnitAssert.EXPECT_FAIL) \
		.is_equal_ignoring_case(["This", "is", "an", "Message"])

func test_is_not_equal():
	assert_array([1, 2, 3, 4, 5]).is_not_equal([1, 2, 3, 4, 5, 6])
	# should fail because the array  contains same elements
	assert_array([1, 2, 3, 4, 5], GdUnitAssert.EXPECT_FAIL) \
		.is_not_equal([1, 2, 3, 4, 5])

func test_is_not_equal_ignoring_case():
	assert_array(["this", "is", "a", "message"]).is_not_equal_ignoring_case(["This", "is", "an", "Message"])
	# should fail because the array contains same elements ignoring case sensitive
	assert_array(["this", "is", "a", "message"], GdUnitAssert.EXPECT_FAIL) \
		.is_not_equal_ignoring_case(["This", "is", "a", "Message"])

func test_is_empty():
	assert_array([]).is_empty()
	# should fail because the array is not empty it has a size of one
	assert_array([1], GdUnitAssert.EXPECT_FAIL) \
		.is_empty()\
		.has_error_message("Expecting:\n must be empty but was\n 1")

func test_is_not_empty():
	assert_array([1]).is_not_empty()
	# should fail because the array is empty
	assert_array([], GdUnitAssert.EXPECT_FAIL) \
		.is_not_empty()\
		.has_error_message("Expecting:\n must not be empty")

func test_has_size():
	assert_array([1, 2, 3, 4, 5]).has_size(5)
	assert_array(["a", "b", "c", "d", "e", "f"]).has_size(6)
	# should fail because the array has a size of 5
	assert_array([1, 2, 3, 4, 5], GdUnitAssert.EXPECT_FAIL) \
		.has_size(4)\
		.has_error_message("Expecting size:\n '4'\n but was\n '5'")

func test_contains():
	assert_array([1, 2, 3, 4, 5]).contains([5, 2])
	# should fail because the array not contains 7 and 6
	assert_array([1, 2, 3, 4, 5], GdUnitAssert.EXPECT_FAIL) \
		.contains([2, 7, 6])\
		.has_error_message("Expecting:\n 1\n2\n3\n4\n5\n do contains\n 2\n7\n6\nbut could not find elements:\n 7\n6")

func test_contains_exactly():
	assert_array([1, 2, 3, 4, 5]).contains_exactly([1, 2, 3, 4, 5])
	# should fail because the array contains the same elements but in a different order
	var expected_error_message := """Expecting to have same elements and in same order:
 1\n2\n3\n4\n5
 1\n4\n3\n2\n5
 but has different order at position '1'
 '2' vs '4'"""
	assert_array([1, 2, 3, 4, 5], GdUnitAssert.EXPECT_FAIL) \
		.contains_exactly([1, 4, 3, 2, 5])\
		.has_error_message(expected_error_message)

func test_fluent():
	assert_array([])\
		.has_size(0)\
		.is_empty()\
		.is_not_null()\
		.contains([])\
		.contains_exactly([])

func test_must_fail_has_invlalid_type():
	assert_array(1, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <int>")
	assert_array(1.3, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <float>")
	assert_array(true, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <bool>")
	assert_array(Resource.new(), GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <Object>")

func test_extract() -> void:
	# try to extract on base types
	assert_array([1, false, 3.14, null, Color.aliceblue]).extract("get_class")\
		.contains_exactly(["n.a.", "n.a.", "n.a.", null, "n.a."])
	# extracting by a func without arguments
	assert_array([Reference.new(), 2, AStar.new(), auto_free(Node.new())]).extract("get_class")\
		.contains_exactly(["Reference", "n.a.", "AStar", "Node"])
	# extracting by a func with arguments
	assert_array([Reference.new(), 2, AStar.new(), auto_free(Node.new())]).extract("has_signal", ["tree_entered"])\
		.contains_exactly([false, "n.a.", false, true])
		
	# try extract on object via a func that not exists
	assert_array([Reference.new(), 2, AStar.new(), auto_free(Node.new())]).extract("invalid_func")\
		.contains_exactly(["n.a.", "n.a.", "n.a.", "n.a."])
	# try extract on object via a func that has no return value
	assert_array([Reference.new(), 2, AStar.new(), auto_free(Node.new())]).extract("remove_meta", [""])\
		.contains_exactly([null, "n.a.", null, null])

class TestObj:
	var _name :String
	var _value
	var _x
	
	func _init(name :String, value, x = null):
		_name = name
		_value = value
		_x = x
	
	func get_name() -> String:
		return _name
	
	func get_value():
		return _value
	
	func get_x():
		return _x
	
	func get_x1() -> String:
		return "x1"
	
	func get_x2() -> String:
		return "x2"
	
	func get_x3() -> String:
		return "x3"
	
	func get_x4() -> String:
		return "x4"
	
	func get_x5() -> String:
		return "x5"
	
	func get_x6() -> String:
		return "x6"
	
	func get_x7() -> String:
		return "x7"
	
	func get_x8() -> String:
		return "x8"
	
	func get_x9() -> String:
		return "x9"

func test_extractv() -> void:
	# single extract
	assert_array([1, false, 3.14, null, Color.aliceblue])\
		.extractv(extr("get_class"))\
		.contains_exactly(["n.a.", "n.a.", "n.a.", null, "n.a."])
	# tuple of two
	assert_array([TestObj.new("A", 10), TestObj.new("B", "foo"), Color.aliceblue, TestObj.new("C", 11)])\
		.extractv(extr("get_name"), extr("get_value"))\
		.contains_exactly([tuple("A", 10), tuple("B", "foo"), tuple("n.a.", "n.a."), tuple("C", 11)])
	# tuple of three
	assert_array([TestObj.new("A", 10), TestObj.new("B", "foo", "bar"), TestObj.new("C", 11, 42)])\
		.extractv(extr("get_name"), extr("get_value"), extr("get_x"))\
		.contains_exactly([tuple("A", 10, null), tuple("B", "foo", "bar"), tuple("C", 11, 42)])

func test_extractv_max_args() -> void:
		assert_array([TestObj.new("A", 10), TestObj.new("B", "foo", "bar"), TestObj.new("C", 11, 42)])\
		.extractv(\
			extr("get_name"),
			extr("get_x1"),
			extr("get_x2"),
			extr("get_x3"),
			extr("get_x4"),
			extr("get_x5"),
			extr("get_x6"),
			extr("get_x7"),
			extr("get_x8"),
			extr("get_x9"))\
		.contains_exactly([
			tuple("A", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9"),
			tuple("B", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9"),
			tuple("C", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9")])

# GdUnit generated TestSuite
class_name GdUnitArrayAssertImpl_PoolByteArrayTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitArrayAssertImpl.gd'

func test_is_null():
	assert_array(null).is_null()
	assert_array(PoolByteArray(), GdUnitAssert.EXPECT_FAIL) \
		.is_null()\
		.has_error_message("Expecting: 'Null' but was empty")

func test_is_not_null():
	assert_array(PoolByteArray()).is_not_null()
	assert_array(null, GdUnitAssert.EXPECT_FAIL) \
		.is_not_null()\
		.has_error_message("Expecting: not to be 'Null'")

func test_is_equal():
	assert_array(PoolByteArray([1, 2, 3, 4, 2, 5])).is_equal(PoolByteArray([1, 2, 3, 4, 2, 5]))
	# should fail because the array not contains same elements and has diff size
	assert_array(PoolByteArray([1, 2, 4, 5]), GdUnitAssert.EXPECT_FAIL) \
		.is_equal(PoolByteArray([1, 2, 3, 4, 2, 5]))

func test_is_equal_ignoring_case():
	assert_array(PoolByteArray(["this", "is", "a", "message"])).is_equal_ignoring_case(PoolByteArray(["This", "is", "a", "Message"]))

func test_is_not_equal():
	assert_array(PoolByteArray([1, 2, 3, 4, 5])).is_not_equal(PoolByteArray([1, 2, 3, 4, 5, 6]))
	# should fail because the array  contains same elements
	assert_array(PoolByteArray([1, 2, 3, 4, 5]), GdUnitAssert.EXPECT_FAIL) \
		.is_not_equal(PoolByteArray([1, 2, 3, 4, 5]))

func test_must_fail_has_invlalid_type():
	assert_array(1, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <int>")
	assert_array(1.3, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <float>")
	assert_array(true, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <bool>")
	assert_array(Resource.new(), GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitArrayAssert inital error, unexpected type <Object>")



func test_is_empty():
	assert_array(PoolByteArray()).is_empty()
	# should fail because the array is not empty
	assert_array(PoolByteArray([1]), GdUnitAssert.EXPECT_FAIL) \
		.is_empty()\
		.has_error_message("Expecting:\n must be empty but was\n 1")

func test_is_not_empty():
	assert_array(PoolByteArray([1])).is_not_empty()
	# should fail because the array is empty
	assert_array(PoolByteArray(), GdUnitAssert.EXPECT_FAIL) \
		.is_not_empty()\
		.has_error_message("Expecting:\n must not be empty")

func test_has_size():
	assert_array(PoolByteArray([1, 2, 3, 4, 5])).has_size(5)
	# should fail because the array has a size of 5
	assert_array(PoolByteArray([1, 2, 3, 4, 5]), GdUnitAssert.EXPECT_FAIL) \
		.has_size(4)\
		.has_error_message("Expecting size:\n '4'\n but was\n '5'")

func test_contains():
	assert_array(PoolByteArray([1, 2, 3, 4, 5])).contains(PoolByteArray([5, 2]))
	# should fail because the array not contains 7 and 6
	assert_array(PoolByteArray([1, 2, 3, 4, 5]), GdUnitAssert.EXPECT_FAIL) \
		.contains(PoolByteArray([2, 7, 6]))\
		.has_error_message("Expecting:\n 1\n2\n3\n4\n5\n do contains\n 2\n7\n6\nbut could not find elements:\n 7\n6")

func test_contains_exactly():
	assert_array(PoolByteArray([1, 2, 3, 4, 5])).contains_exactly(PoolByteArray([1, 2, 3, 4, 5]))
	# should fail because the array not contains same elements but in different order
	var expected_error_message := """Expecting to have same elements and in same order:
 1\n2\n3\n4\n5
 1\n4\n3\n2\n5
 but has different order at position '1'
 '2' vs '4'"""
	assert_array(PoolByteArray([1, 2, 3, 4, 5]), GdUnitAssert.EXPECT_FAIL) \
		.contains_exactly(PoolByteArray([1, 4, 3, 2, 5]))\
		.has_error_message(expected_error_message)
		

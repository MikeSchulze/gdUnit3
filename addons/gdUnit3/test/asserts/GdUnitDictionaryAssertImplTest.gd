# GdUnit generated TestSuite
class_name GdUnitDictionaryAssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitDictionaryAssertImpl.gd'

func test_must_fail_has_invlalid_type():
	assert_dict(1, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitDictionaryAssert inital error, unexpected type <int>")
	assert_dict(1.3, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitDictionaryAssert inital error, unexpected type <float>")
	assert_dict(true, GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitDictionaryAssert inital error, unexpected type <bool>")
	assert_dict("abc", GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitDictionaryAssert inital error, unexpected type <String>")
	assert_dict([], GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitDictionaryAssert inital error, unexpected type <Array>")
	assert_dict(Resource.new(), GdUnitAssert.EXPECT_FAIL) \
		.has_error_message("GdUnitDictionaryAssert inital error, unexpected type <Object>")

func test_is_null():
	assert_dict(null).is_null()
	
	assert_dict({}, GdUnitAssert.EXPECT_FAIL)\
		.is_null()\
		.has_error_message("Expecting: 'Null' but was '{}'")

func test_is_not_null():
	assert_dict({}).is_not_null()
	
	assert_dict(null, GdUnitAssert.EXPECT_FAIL)\
		.is_not_null()\
		.has_error_message("Expecting: not to be 'Null'")
		

func test_is_equal():
	assert_dict({}).is_equal({})
	assert_dict({1:1}).is_equal({1:1})
	assert_dict({1:1, "key_a": "value_a"}).is_equal({1:1, "key_a": "value_a" })
	# different order is also equals
	assert_dict({"key_a": "value_a", 1:1}).is_equal({1:1, "key_a": "value_a" })
	
	# should fail
	assert_dict(null, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1})
		
	assert_dict({}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1})
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({})
	
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:2})
	assert_dict({1:2}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1})
		
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1, "key_a": "value_a"})
	assert_dict({1:1, "key_a": "value_a"}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1})
		
	assert_dict({1:1, "key_a": "value_a"}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1, "key_b": "value_b"})
	assert_dict({1:1, "key_b": "value_b"}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1, "key_a": "value_a"})

	assert_dict({"key_a": "value_a", 1:1}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({1:1, "key_b": "value_b"})
	assert_dict({1:1, "key_b": "value_b"}, GdUnitAssert.EXPECT_FAIL)\
		.is_equal({"key_a": "value_a", 1:1})

func test_is_not_equal():
	assert_dict(null).is_not_equal({})
	assert_dict({}).is_not_equal(null)
	assert_dict({}).is_not_equal({1:1})
	assert_dict({1:1}).is_not_equal({})
	assert_dict({1:1}).is_not_equal({1:2})
	assert_dict({2:1}).is_not_equal({1:1})
	assert_dict({1:1}).is_not_equal({1:1, "key_a": "value_a"})
	assert_dict({1:1, "key_a": "value_a"}).is_not_equal({1:1})
	assert_dict({1:1, "key_a": "value_a"}).is_not_equal({1:1,  "key_b": "value_b"})
	
	# should fail
	assert_dict({}, GdUnitAssert.EXPECT_FAIL)\
		.is_not_equal({})
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.is_not_equal({1:1})
	assert_dict({1:1, "key_a": "value_a"}, GdUnitAssert.EXPECT_FAIL)\
		.is_not_equal({1:1, "key_a": "value_a"})
	assert_dict({"key_a": "value_a", 1:1}, GdUnitAssert.EXPECT_FAIL)\
		.is_not_equal({1:1, "key_a": "value_a"})

func test_is_empty():
	assert_dict({}).is_empty()
	
	assert_dict(null, GdUnitAssert.EXPECT_FAIL)\
		.is_empty()
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.is_empty()

func test_is_not_empty():
	assert_dict({1:1}).is_not_empty()
	assert_dict({1:1, "key_a": "value_a"}).is_not_empty()
	
	assert_dict(null, GdUnitAssert.EXPECT_FAIL)\
		.is_not_empty()
	assert_dict({}, GdUnitAssert.EXPECT_FAIL)\
		.is_not_empty()

func test_has_size():
	assert_dict({}).has_size(0)
	assert_dict({1:1}).has_size(1)
	assert_dict({1:1, 2:1}).has_size(2)
	assert_dict({1:1, 2:1, 3:1}).has_size(3)
	
	assert_dict(null, GdUnitAssert.EXPECT_FAIL)\
		.has_size(0)
	assert_dict(null, GdUnitAssert.EXPECT_FAIL)\
		.has_size(1)
	assert_dict({}, GdUnitAssert.EXPECT_FAIL)\
		.has_size(1)
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.has_size(0)
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.has_size(2)

func test_contains_keys():
	assert_dict({1:1, 2:2, 3:3}).contains_keys([2])
	assert_dict({1:1, 2:2, "key_a": "value_a"}).contains_keys([2, "key_a"])
	
	assert_dict({1:1, 3:3}, GdUnitAssert.EXPECT_FAIL)\
		.contains_keys([2])\
		.has_error_message("Expecting keys:\n 1, 3\n to contains:\n 2\n but can't find key's:\n 2")
	assert_dict({1:1, 3:3}, GdUnitAssert.EXPECT_FAIL)\
		.contains_keys([1, 4])\
		.has_error_message("Expecting keys:\n 1, 3\n to contains:\n 1, 4\n but can't find key's:\n 4")

func test_contains_not_keys():
	assert_dict({}).contains_not_keys([2])
	assert_dict({1:1, 3:3}).contains_not_keys([2])
	assert_dict({1:1, 3:3}).contains_not_keys([2, 4])
	
	assert_dict({1:1, 2:2, 3:3}, GdUnitAssert.EXPECT_FAIL)\
		.contains_not_keys([2, 4])\
		.has_error_message("Expecting keys:\n 1, 2, 3\n do not contains:\n 2, 4\n but contains key's:\n 2")
	assert_dict({1:1, 2:2, 3:3}, GdUnitAssert.EXPECT_FAIL)\
		.contains_not_keys([1, 2, 3, 4])\
		.has_error_message("Expecting keys:\n 1, 2, 3\n do not contains:\n 1, 2, 3, 4\n but contains key's:\n 1, 2, 3")

func test_contains_key_value():
	assert_dict({1:1}).contains_key_value(1, 1)
	assert_dict({1:1, 2:2, 3:3}).contains_key_value(3, 3).contains_key_value(1, 1)
	
	assert_dict({1:1}, GdUnitAssert.EXPECT_FAIL)\
		.contains_key_value(1, 2)\
		.has_error_message("Expecting key and value:\n '1' : '2'\n but contains\n '1' : '1'")

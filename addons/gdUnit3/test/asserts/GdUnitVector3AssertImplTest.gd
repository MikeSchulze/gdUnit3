# GdUnit generated TestSuite
class_name GdUnitVector3AssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitVector3AssertImpl.gd'

func test_is_null():
	assert_vector3(null).is_null()
	# should fail because the current is not null
	assert_vector3(Vector3.ONE, GdUnitAssert.EXPECT_FAIL) \
		.is_null()\
		.starts_with_failure_message("Expecting: 'Null' but was '(1, 1, 1)'")

func test_is_not_null():
	assert_vector3(Vector3.ONE).is_not_null()
	# should fail because the current is null
	assert_vector3(null, GdUnitAssert.EXPECT_FAIL) \
		.is_not_null()\
		.has_failure_message("Expecting: not to be 'Null'")

func test_is_equal() -> void:
	assert_vector3(Vector3.ONE).is_equal(Vector3.ONE)
	assert_vector3(Vector3.INF).is_equal(Vector3.INF)
	assert_vector3(Vector3(1.2, 1.000001, 1)).is_equal(Vector3(1.2, 1.000001, 1))
	
	# false test
	assert_vector3(Vector3.ONE, GdUnitAssert.EXPECT_FAIL)\
		.is_equal(Vector3(1.2, 1.000001, 1))\
		.has_failure_message("Expecting:\n '(1.2, 1.000001, 1)'\n but was\n '(1, 1, 1)'")

func test_is_not_equal() -> void:
	assert_vector3(Vector3.ONE).is_not_equal(Vector3.INF)
	assert_vector3(Vector3.INF).is_not_equal(Vector3.ONE)
	assert_vector3(Vector3(1.2, 1.000001, 1)).is_not_equal(Vector3(1.2, 1.000002, 1))
	
	# false test
	assert_vector3(Vector3(1.2, 1.000001, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_not_equal(Vector3(1.2, 1.000001, 1))\
		.has_failure_message("Expecting:\n '(1.2, 1.000001, 1)'\n not equal to\n '(1.2, 1.000001, 1)'")

func test_is_equal_approx() -> void:
	assert_vector3(Vector3.ONE).is_equal_approx(Vector3.ONE, Vector3(0.004, 0.004, 0.004))
	assert_vector3(Vector3(0.996, 0.996, 0.996)).is_equal_approx(Vector3.ONE, Vector3(0.004, 0.004, 0.004))
	assert_vector3(Vector3(1.004, 1.004, 1.004)).is_equal_approx(Vector3.ONE, Vector3(0.004, 0.004, 0.004))
	
	# false test
	assert_vector3(Vector3(1.005, 1, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_equal_approx(Vector3.ONE, Vector3(0.004, 0.004, 0.004))\
		.has_failure_message("Expecting:\n '(1.005, 1, 1)'\n in range between\n '(0.996, 0.996, 0.996)' <> '(1.004, 1.004, 1.004)'")
	assert_vector3(Vector3(1, 0.995, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_equal_approx(Vector3.ONE, Vector3(0, 0.004, 0))\
		.has_failure_message("Expecting:\n '(1, 0.995, 1)'\n in range between\n '(1, 0.996, 1)' <> '(1, 1.004, 1)'")

func test_is_less() -> void:
	assert_vector3(Vector3.ONE).is_less(Vector3.INF)
	assert_vector3(Vector3(1.2, 1.00001, 1)).is_less(Vector3(1.2, 1.00002, 1))
	
	# false test
	assert_vector3(Vector3.ONE, GdUnitAssert.EXPECT_FAIL)\
		.is_less(Vector3.ONE)\
		.has_failure_message("Expecting to be less than:\n '(1, 1, 1)' but was '(1, 1, 1)'")
	assert_vector3(Vector3(1.2, 1.000001, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_less(Vector3(1.2, 1.000001, 1))\
		.has_failure_message("Expecting to be less than:\n '(1.2, 1.000001, 1)' but was '(1.2, 1.000001, 1)'")

func test_is_less_equal() -> void:
	assert_vector3(Vector3.ONE).is_less_equal(Vector3.INF)
	assert_vector3(Vector3(1.2, 1.000001, 1)).is_less_equal(Vector3(1.2, 1.000001, 1))
	assert_vector3(Vector3(1.2, 1.000001, 1)).is_less_equal(Vector3(1.2, 1.000002, 1))
	
	# false test
	assert_vector3(Vector3.ONE, GdUnitAssert.EXPECT_FAIL)\
		.is_less_equal(Vector3.ZERO)\
		.has_failure_message("Expecting to be less than or equal:\n '(0, 0, 0)' but was '(1, 1, 1)'")
	assert_vector3(Vector3(1.2, 1.00002, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_less_equal(Vector3(1.2, 1.00001, 1))\
		.has_failure_message("Expecting to be less than or equal:\n '(1.2, 1.00001, 1)' but was '(1.2, 1.00002, 1)'")


func test_is_greater() -> void:
	assert_vector3(Vector3.INF).is_greater(Vector3.ONE)
	assert_vector3(Vector3(1.2, 1.00002, 1)).is_greater(Vector3(1.2, 1.00001, 1))
	
	# false test
	assert_vector3(Vector3.ZERO, GdUnitAssert.EXPECT_FAIL)\
		.is_greater(Vector3.ONE)\
		.has_failure_message("Expecting to be greater than:\n '(1, 1, 1)' but was '(0, 0, 0)'")
	assert_vector3(Vector3(1.2, 1.000001, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_greater(Vector3(1.2, 1.000001, 1))\
		.has_failure_message("Expecting to be greater than:\n '(1.2, 1.000001, 1)' but was '(1.2, 1.000001, 1)'")

func test_is_greater_equal() -> void:
	assert_vector3(Vector3.INF).is_greater_equal(Vector3.ONE)
	assert_vector3(Vector3.ONE).is_greater_equal(Vector3.ONE)
	assert_vector3(Vector3(1.2, 1.000001, 1)).is_greater_equal(Vector3(1.2, 1.000001, 1))
	assert_vector3(Vector3(1.2, 1.000002, 1)).is_greater_equal(Vector3(1.2, 1.000001, 1))
	
	# false test
	assert_vector3(Vector3.ZERO, GdUnitAssert.EXPECT_FAIL)\
		.is_greater_equal(Vector3.ONE)\
		.has_failure_message("Expecting to be greater than or equal:\n '(1, 1, 1)' but was '(0, 0, 0)'")
	assert_vector3(Vector3(1.2, 1.00002, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_greater_equal(Vector3(1.2, 1.00003, 1))\
		.has_failure_message("Expecting to be greater than or equal:\n '(1.2, 1.00003, 1)' but was '(1.2, 1.00002, 1)'")

func test_is_between(fuzzer = Fuzzers.rangev3(Vector3.ZERO, Vector3.ONE)):
	var value :Vector3 = fuzzer.next_value()
	assert_vector3(value).is_between(Vector3.ZERO, Vector3.ONE)

func test_is_between_fail():
	assert_vector3(Vector3(1, 1.00001, 1), GdUnitAssert.EXPECT_FAIL)\
		.is_between(Vector3.ZERO, Vector3.ONE)\
		.has_failure_message("Expecting:\n '(1, 1.00001, 1)'\n in range between\n '(0, 0, 0)' <> '(1, 1, 1)'")

func test_is_not_between(fuzzer = Fuzzers.rangev3(Vector3.ZERO, Vector3.ONE)):
	var value :Vector3 = fuzzer.next_value()
	assert_vector3(Vector3(1, 1.0002, 1)).is_not_between(Vector3.ZERO, Vector3.ONE)

func test_is_not_between_fail():
	assert_vector3(Vector3.ONE, GdUnitAssert.EXPECT_FAIL)\
		.is_not_between(Vector3.ZERO, Vector3.ONE)\
		.has_failure_message("Expecting:\n '(1, 1, 1)'\n not in range between\n '(0, 0, 0)' <> '(1, 1, 1)'")

func test_override_failure_message() -> void:
	assert_vector2(Vector3.ONE, GdUnitAssert.EXPECT_FAIL)\
		.override_failure_message("Custom failure message")\
		.is_null()\
		.has_failure_message("Custom failure message")

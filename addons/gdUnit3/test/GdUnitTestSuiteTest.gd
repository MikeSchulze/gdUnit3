# GdUnit generated TestSuite
class_name GdUnitTestSuiteTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/GdUnitTestSuite.gd'

func test_assert_that_types() -> void:
	assert_object(assert_that(true)).is_instanceof(GdUnitBoolAssert)
	assert_object(assert_that(1)).is_instanceof(GdUnitIntAssert)
	assert_object(assert_that(3.12)).is_instanceof(GdUnitFloatAssert)
	assert_object(assert_that("abc")).is_instanceof(GdUnitStringAssert)
	assert_object(assert_that(Vector2.ONE)).is_instanceof(GdUnitVector2Assert)
	assert_object(assert_that([])).is_instanceof(GdUnitArrayAssert)
	assert_object(assert_that({})).is_instanceof(GdUnitDictionaryAssert)
	assert_object(assert_that(Result.new())).is_instanceof(GdUnitObjectAssert)

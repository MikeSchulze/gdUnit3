# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdTestParameterSetTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/parse/GdTestParameterSet.gd'

func vec2_as_string(v :Vector2) -> String:
	return "Vector2" + str(v)

func vec3_as_string(v :Vector3) -> String:
	return "Vector3" + str(v)

func test_constants():
	assert_that(GdTestParameterSet.Vector2_ZERO).is_equal(vec2_as_string(Vector2.ZERO))
	assert_that(GdTestParameterSet.Vector2_ONE).is_equal(vec2_as_string(Vector2.ONE))
	assert_that(GdTestParameterSet.Vector2_RIGHT).is_equal(vec2_as_string(Vector2.RIGHT))
	assert_that(GdTestParameterSet.Vector2_LEFT).is_equal(vec2_as_string(Vector2.LEFT))
	assert_that(GdTestParameterSet.Vector2_DOWN).is_equal(vec2_as_string(Vector2.DOWN))
	assert_that(GdTestParameterSet.Vector2_UP).is_equal(vec2_as_string(Vector2.UP))
	assert_that(GdTestParameterSet.Vector2_INF).is_equal(vec2_as_string(Vector2.INF))
	
	assert_that(GdTestParameterSet.Vector3_DOWN).is_equal(vec3_as_string(Vector3.DOWN))
	assert_that(GdTestParameterSet.Vector3_ZERO).is_equal(vec3_as_string(Vector3.ZERO))
	assert_that(GdTestParameterSet.Vector3_ONE).is_equal(vec3_as_string(Vector3.ONE))
	assert_that(GdTestParameterSet.Vector3_RIGHT).is_equal(vec3_as_string(Vector3.RIGHT))
	assert_that(GdTestParameterSet.Vector3_LEFT).is_equal(vec3_as_string(Vector3.LEFT))
	assert_that(GdTestParameterSet.Vector3_DOWN).is_equal(vec3_as_string(Vector3.DOWN))
	assert_that(GdTestParameterSet.Vector3_UP).is_equal(vec3_as_string(Vector3.UP))
	assert_that(GdTestParameterSet.Vector3_FORWARD).is_equal(vec3_as_string(Vector3.FORWARD))
	assert_that(GdTestParameterSet.Vector3_BACK).is_equal(vec3_as_string(Vector3.BACK))
	assert_that(GdTestParameterSet.Vector3_INF).is_equal(vec3_as_string(Vector3.INF))

func test_convert_vector2_constants() -> void:
	var vectors = "[Vector2.ZERO, Vector2.ONE, Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.INF, Vector2(3.2, 4.2)]"
	assert_that(GdTestParameterSet._convert_vector2_constants(vectors))\
		.is_equal("[Vector2(0, 0), Vector2(1, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1.#INF, 1.#INF), Vector2(3.2, 4.2)]")

func test_convert_vector3_constants() -> void:
	var vectors = "[Vector3.ZERO, Vector3.ONE, Vector3.LEFT, Vector3.RIGHT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK, Vector3.INF, Vector3(3.2, 4.2, 1.2)]"
	assert_that(GdTestParameterSet._convert_vector3_constants(vectors))\
		.is_equal("[Vector3(0, 0, 0), Vector3(1, 1, 1), Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0), Vector3(0, 0, -1), Vector3(0, 0, 1), Vector3(1.#INF, 1.#INF, 1.#INF), Vector3(3.2, 4.2, 1.2)]")

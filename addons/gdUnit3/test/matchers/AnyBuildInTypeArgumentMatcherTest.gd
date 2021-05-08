# GdUnit generated TestSuite
class_name AnyBuildInTypeArgumentMatcherTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/matchers/AnyBuildInTypeArgumentMatcher.gd'


func test_is_match_bool() -> void:
	assert_object(any_bool()).is_instanceof(AnyBuildInTypeArgumentMatcher)
	
	var matcher := any_bool()
	assert_bool(matcher.is_match(true)).is_true()
	assert_bool(matcher.is_match(false)).is_true()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match(0)).is_false()
	assert_bool(matcher.is_match(0.2)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_is_match_int() -> void:
	assert_object(any_int()).is_instanceof(AnyBuildInTypeArgumentMatcher)
	
	var matcher := any_int()
	assert_bool(matcher.is_match(0)).is_true()
	assert_bool(matcher.is_match(1000)).is_true()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match([])).is_false()
	assert_bool(matcher.is_match(0.2)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_is_match_float() -> void:
	assert_object(any_float()).is_instanceof(AnyBuildInTypeArgumentMatcher)
	
	var matcher := any_float()
	assert_bool(matcher.is_match(.0)).is_true()
	assert_bool(matcher.is_match(0.0)).is_true()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match([])).is_false()
	assert_bool(matcher.is_match(1000)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_is_match_string() -> void:
	assert_object(any_string()).is_instanceof(AnyBuildInTypeArgumentMatcher)
	
	var matcher := any_string()
	assert_bool(matcher.is_match("")).is_true()
	assert_bool(matcher.is_match("abc")).is_true()
	assert_bool(matcher.is_match(0)).is_false()
	assert_bool(matcher.is_match(1000)).is_false()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match([])).is_false()
	assert_bool(matcher.is_match(0.2)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_is_match_color() -> void:
	assert_object(any_color()).is_instanceof(AnyBuildInTypeArgumentMatcher)
	
	var matcher := any_color()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match("abc")).is_false()
	assert_bool(matcher.is_match(0)).is_false()
	assert_bool(matcher.is_match(1000)).is_false()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match(Color.aliceblue)).is_true()
	assert_bool(matcher.is_match(Color.red)).is_true()

func test_is_match_vector2() -> void:
	assert_object(any_vector2()).is_instanceof(AnyBuildInTypeArgumentMatcher)
	
	var matcher := any_vector2()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match("abc")).is_false()
	assert_bool(matcher.is_match(0)).is_false()
	assert_bool(matcher.is_match(1000)).is_false()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match(Vector2.DOWN)).is_true()
	assert_bool(matcher.is_match(Vector2.ONE)).is_true()
	assert_bool(matcher.is_match(Vector3.DOWN)).is_false()

func test_is_match_vector3() -> void:
	assert_object(any_vector3()).is_instanceof(AnyBuildInTypeArgumentMatcher)
	
	var matcher := any_vector3()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match("abc")).is_false()
	assert_bool(matcher.is_match(0)).is_false()
	assert_bool(matcher.is_match(1000)).is_false()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match(Vector2.DOWN)).is_false()
	assert_bool(matcher.is_match(Vector3.DOWN)).is_true()
	assert_bool(matcher.is_match(Vector3.ONE)).is_true()

# GdUnit generated TestSuite
class_name AnyFloatArgumentMatcherTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/matchers/AnyFloatArgumentMatcher.gd'

func test_is_match():
	var matcher := AnyFloatArgumentMatcher.new()
	
	assert_bool(matcher.is_match(.0)).is_true()
	assert_bool(matcher.is_match(0.0)).is_true()
	
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match([])).is_false()
	assert_bool(matcher.is_match(1000)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_any_float():
	assert_object(any_float()).is_instanceof(AnyFloatArgumentMatcher)

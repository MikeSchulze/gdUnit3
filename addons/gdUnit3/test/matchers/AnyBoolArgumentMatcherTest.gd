# GdUnit generated TestSuite
class_name AnyBoolArgumentMatcherTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/matchers/AnyBoolArgumentMatcher.gd'

func test_is_match():
	var matcher := AnyBoolArgumentMatcher.new()
	
	assert_bool(matcher.is_match(true)).is_true()
	assert_bool(matcher.is_match(false)).is_true()
	
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match(0)).is_false()
	assert_bool(matcher.is_match(0.2)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_any_bool():
	assert_object(any_bool()).is_instanceof(AnyBoolArgumentMatcher)

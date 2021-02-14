# GdUnit generated TestSuite
class_name AnyStringArgumentMatcherTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/matchers/AnyStringArgumentMatcher.gd'

func test_is_match():
	var matcher := AnyStringArgumentMatcher.new()
	
	assert_bool(matcher.is_match("")).is_true()
	assert_bool(matcher.is_match("abc")).is_true()
	
	assert_bool(matcher.is_match(0)).is_false()
	assert_bool(matcher.is_match(1000)).is_false()
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match([])).is_false()
	assert_bool(matcher.is_match(0.2)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_any_string():
	assert_object(any_string()).is_instanceof(AnyStringArgumentMatcher)

# GdUnit generated TestSuite
class_name AnyIntArgumentMatcherTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/matchers/AnyIntArgumentMatcher.gd'

func test_is_match():
	var matcher := AnyIntArgumentMatcher.new()
	
	assert_bool(matcher.is_match(0)).is_true()
	assert_bool(matcher.is_match(1000)).is_true()
	
	assert_bool(matcher.is_match(null)).is_false()
	assert_bool(matcher.is_match("")).is_false()
	assert_bool(matcher.is_match([])).is_false()
	assert_bool(matcher.is_match(0.2)).is_false()
	assert_bool(matcher.is_match(auto_free(Node.new()))).is_false()

func test_any_int():
	assert_object(any_int()).is_instanceof(AnyIntArgumentMatcher)

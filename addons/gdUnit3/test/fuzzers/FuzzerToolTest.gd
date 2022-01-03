extends GdUnitTestSuite

const MIN_VALUE := -10
const MAX_VALUE := 22

static func _s_max_value() -> int:
	return MAX_VALUE

func min_value() -> int:
	return MIN_VALUE

func fuzzer() -> Fuzzer:
	return Fuzzers.rangei(min_value(), _s_max_value())
	
func non_fuzzer() -> Resource:
	return Image.new()

func test_create_fuzzer_argument_default():
	var fuzzer_func := "fuzzer:=Fuzzers.rangei(-10, 22)"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_not_null()
	assert_that(fuzzer).is_instanceof(Fuzzer)
	assert_int(fuzzer.next_value()).is_between(-10, 22)

func test_create_fuzzer_argument_with_constants():
	var fuzzer_func := "fuzzer:=Fuzzers.rangei(-10, MAX_VALUE)"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_not_null()
	assert_that(fuzzer).is_instanceof(Fuzzer)
	assert_int(fuzzer.next_value()).is_between(-10, 22)

func test_create_fuzzer_argument_with_custom_function():
	var fuzzer_func := "fuzzer:=fuzzer()"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_not_null()
	assert_that(fuzzer).is_instanceof(Fuzzer)
	assert_int(fuzzer.next_value()).is_between(MIN_VALUE, MAX_VALUE)

func test_create_fuzzer_do_fail():
	var fuzzer_func := "fuzzer:=non_fuzzer()"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_null()

class NestedFuzzer extends Fuzzer:
	
	func _init():
		pass
	
	func next_value()->Dictionary: 
		return {}

func test_create_nested_fuzzer_do_fail():
	var fuzzer_func := "fuzzer:=NestedFuzzer.new()"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_not_null()
	assert_that(fuzzer is Fuzzer).is_true()
	# the fuzzer is not typed as NestedFuzzer seams be a Godot bug
	assert_bool(fuzzer is NestedFuzzer).is_false()

func test_create_external_fuzzer():
	var fuzzer_func := "fuzzer:=TestExternalFuzzer.new()"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_not_null()
	assert_that(fuzzer is Fuzzer).is_true()
	assert_bool(fuzzer is TestExternalFuzzer).is_true()

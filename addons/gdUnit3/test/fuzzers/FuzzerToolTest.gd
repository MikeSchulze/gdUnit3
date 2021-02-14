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
	assert_int(fuzzer.next_value()).is_in_range(-10, 22)

func test_create_fuzzer_argument_with_constants():
	var fuzzer_func := "fuzzer:=Fuzzers.rangei(-10, MAX_VALUE)"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_not_null()
	assert_that(fuzzer).is_instanceof(Fuzzer)
	assert_int(fuzzer.next_value()).is_in_range(-10, 22)

func test_create_fuzzer_argument_with_custom_function():
	var fuzzer_func := "fuzzer:=fuzzer()"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_not_null()
	assert_that(fuzzer).is_instanceof(Fuzzer)
	assert_int(fuzzer.next_value()).is_in_range(MIN_VALUE, MAX_VALUE)

func test_create_fuzzer_do_fail():
	var fuzzer_func := "fuzzer:=non_fuzzer()"
	var fuzzer := FuzzerTool.create_fuzzer(self.get_script(), fuzzer_func)
	assert_that(fuzzer).is_null()

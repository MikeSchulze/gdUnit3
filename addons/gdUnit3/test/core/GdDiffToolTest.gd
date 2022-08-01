# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdDiffToolTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdDiffTool.gd'

func test_string_diff_empty():
	var diffs := GdDiffTool.string_diff("", "")
	assert_array(diffs).has_size(2)
	assert_array(diffs[0].to_ascii()).is_empty()
	assert_array(diffs[1].to_ascii()).is_empty()

func test_string_diff_equals():
	var diffs := GdDiffTool.string_diff("Abc", "Abc")
	var expected_l_diff = PoolByteArray([ord('A'), ord('b'), ord('c')])
	var expected_r_diff = PoolByteArray([ord('A'), ord('b'), ord('c')])
	
	assert_array(diffs).has_size(2)
	assert_array(diffs[0].to_ascii()).contains_exactly(expected_l_diff)
	assert_array(diffs[1].to_ascii()).contains_exactly(expected_r_diff)

func test_string_diff():
	# tests the result of string diff function like assert_str("Abc").is_equal("abc")
	var diffs := GdDiffTool.string_diff("Abc", "abc")
	
	var expected_l_diff = PoolByteArray([GdDiffTool.DIV_SUB, ord('A'), GdDiffTool.DIV_ADD, ord('a'), ord('b'), ord('c')])
	var expected_r_diff = PoolByteArray([GdDiffTool.DIV_ADD, ord('A'), GdDiffTool.DIV_SUB, ord('a'), ord('b'), ord('c')])
	
	assert_array(diffs).has_size(2)
	assert_array(diffs[0].to_ascii()).contains_exactly(expected_l_diff)
	assert_array(diffs[1].to_ascii()).contains_exactly(expected_r_diff)

func test_string_diff_large_value(fuzzer := Fuzzers.rand_str(1000, 4000), fuzzer_iterations = 10):
	# test diff with large values not crashes the API GD-100
	var value :String = fuzzer.next_value()
	GdDiffTool.string_diff(value, value)

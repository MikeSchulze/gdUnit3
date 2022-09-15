class_name ParameterizedTestSuite
extends GdUnitTestSuite


func test_no_parameters():
	pass

func test_parameterized(a: int, b :int, c :int, expected :int, test_parameters := [
	[1, 2, 3, 6],
	[3, 4, 5, 11],
	[6, 7, 8, 21] ]):
	
	assert_that(a+b+c).is_equal(expected)

func test_parameterized_to_less_args(a: int, b :int, expected :int, test_parameters := [
	[1, 2, 3, 6],
	[3, 4, 5, 11],
	[6, 7, 8, 21] ]):
	pass

func test_parameterized_to_many_args(a: int, b :int, c :int, d :int, expected :int, test_parameters := [
	[1, 2, 3, 6],
	[3, 4, 5, 11],
	[6, 7, 8, 21] ]):
	pass

func test_parameterized_to_less_args_at_index_1(a: int, b :int, expected :int, test_parameters := [
	[1, 2, 6],
	[3, 4, 5, 11],
	[6, 7, 21] ]):
	pass

func test_parameterized_invalid_struct(a: int, b :int, expected :int, test_parameters := [
	[1, 2, 6],
	"foo",
	[6, 7, 21] ]):
	pass

func test_parameterized_invalid_args(a: int, b :int, expected :int, test_parameters := [
	[1, 2, 6],
	[3, "4", 11],
	[6, 7, 21] ]):
	pass

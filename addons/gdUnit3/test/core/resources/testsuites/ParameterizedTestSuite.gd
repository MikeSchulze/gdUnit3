class_name ParameterizedTestSuite
extends GdUnitTestSuite


func test_no_parameters():
	pass

func _test_parameterized(a: int, b :int, c :int, expected :int, parameters = [
	[1, 2, 3, 6],
	[3, 4, 5, 11],
	[6, 7, 8, 21] ]):
	
	assert_that(a+b+c).is_equal(expected)

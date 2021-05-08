# GdUnit generated TestSuite
class_name ExampleWithSignalTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://examples/mocking/src/ExampleWithSignal.gd'

func test_foo_emits_test_signal_a() -> void:
	# build a mock for class ExampleWithSignal and we using call real implementation
	var mock :ExampleWithSignal = mock(ExampleWithSignal, CALL_REAL_FUNC)
	
	# we did not initially have any recorded interactions on this mock
	verify_no_interactions(mock)
	
	# call function foo with value 0 
	mock.foo(0)
	# we expect a signal "test_signal_a" with argument "a : fight" is emited
	verify(mock).emit_signal("test_signal_a", "a : fight")
	# we also now the code calles 'create_fighter' with arg '"a"' to build the signal
	# we can verify it by
	verify(mock).create_fighter("a")
	
	# and we expect no signal "test_signal_b" is emited
	# for simplify testing we use any() and any_bool() because we want to match 
	# for all posible signal argument combinations
	verify(mock, 0).emit_signal("test_signal_b", any(), any_bool())
	# also 'create_fighter' with arg '"b"' is never called
	verify(mock, 0).create_fighter("b")
	# and we can also verify we have called `foo` with argument '0'
	verify(mock).foo(0)
	
	
	# now we want to test emit signal with an custom fighter
	# so we have to 'override' the 'create_fighter' to return a custom value
	# return a new FooFighter when 'create_fighter("a")' is called on the mock
	do_return(ExampleWithSignal.FooFighter.new("my custom"))\
		.on(mock)\
		.create_fighter("a")
	# call again function foo with value 0 
	mock.foo(0)
	# now we expect a signal "test_signal_a" with special mocked value is called
	verify(mock, 1).emit_signal("test_signal_a", "my custom : fight")
	
	# Lastly, we want to make sure that we have no other interactions on this mock
	verify_no_more_interactions(mock)

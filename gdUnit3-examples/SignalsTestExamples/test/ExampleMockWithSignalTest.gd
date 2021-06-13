# GdUnit generated TestSuite
class_name ExampleMockWithSignalTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://gdUnit3-examples/mocking/src/ExampleWithSignal.gd'

func test_mock_default_mode() -> void:
	# build a mock for class ExampleWithSignal (default mode RETURN_DEFAULTS)
	# default mode means no real implementation is called and a default value is returnd instead
	# this mode is usefull when you need a not fully initalisized object for testing
	# you have to override (mock) functions to return a specific value
	var mock :ExampleWithSignal = mock(ExampleWithSignal)
	
	# we did not initially have any recorded interactions on this mock
	verify_no_interactions(mock)
	
	# call function foo with value 0 
	mock.foo(0)
	
	# and we can verify we have called `foo` with argument '0'
	verify(mock).foo(0)
	
	# and no more other interactions on this mock was hapen
	verify_no_more_interactions(mock)
	
	# if you call a function a 'default' value based on return type is returnd
	assert_object(mock.create_fighter("a")).is_null()
	
	# We can 'override' a function that returns a user-defined value for a specific argument.
	# in this case for 'create_fighter("a")' and 'create_fighter("b")'
	do_return(ExampleWithSignal.FooFighter.new("my fighter a"))\
		.on(mock)\
		.create_fighter("a")
	do_return(ExampleWithSignal.FooFighter.new("my fighter b"))\
		.on(mock)\
		.create_fighter("b")
	# let check this works
	assert_object(mock.create_fighter("a")).is_equal(ExampleWithSignal.FooFighter.new("my fighter a"))
	assert_object(mock.create_fighter("b")).is_equal(ExampleWithSignal.FooFighter.new("my fighter b"))

func test_foo_emits_test_signal_a() -> void:
	# build a mock for class ExampleWithSignal and we using mode CALL_REAL_FUNC
	# on this mode the real implementaion is called
	# you can still override (mock) implementations  
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

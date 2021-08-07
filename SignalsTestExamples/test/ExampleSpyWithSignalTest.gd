# GdUnit generated TestSuite
class_name ExampleSpyWithSignalTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://gdUnit3-examples/mocking/src/ExampleWithSignal.gd'

func test_foo_emits_test_signal_a() -> void:
	# build a spy_instance from the ExampleWithSignal instance
	var spy_instance :ExampleWithSignal = spy(ExampleWithSignal.new())
	
	# we did not initially have any recorded interactions on this spy_instance
	verify_no_interactions(spy_instance)
	
	# call function foo with value 0 
	spy_instance.foo(0)
	# we expect a signal "test_signal_a" with argument "a : fight" is emited
	verify(spy_instance).emit_signal("test_signal_a", "a : fight")
	# we also now the code calles 'create_fighter' with arg '"a"' to build the signal
	# we can verify it by
	verify(spy_instance).create_fighter("a")
	
	# and we expect no signal "test_signal_b" is emited
	# for simplify testing we use any() and any_bool() because we want to match 
	# for all posible signal argument combinations
	verify(spy_instance, 0).emit_signal("test_signal_b", any(), any_bool())
	# also 'create_fighter' with arg '"b"' is never called
	verify(spy_instance, 0).create_fighter("b")
	# and we can also verify we have called `foo` with argument '0'
	verify(spy_instance).foo(0)
	
	# Lastly, we want to make sure that we have no other interactions on this spy_instance
	verify_no_more_interactions(spy_instance)

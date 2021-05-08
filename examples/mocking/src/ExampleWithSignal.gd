class_name ExampleWithSignal
extends Reference


signal test_signal_a
signal test_signal_b

class FooFighter:
	var _value :String
	
	func _init(value :String):
		_value = value
	
	func fight() -> String:
		return _value + " : " + "fight"

func foo(arg :int) -> void:
	if arg == 0:
		emit_signal("test_signal_a", create_fighter("a").fight())
	else:
		emit_signal("test_signal_b", create_fighter("b").fight(), true)

func create_fighter(value :String) -> FooFighter:
	return FooFighter.new(value)


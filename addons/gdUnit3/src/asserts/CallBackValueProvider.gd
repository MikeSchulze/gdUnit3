# a value provider unsing a callback to get `next` value from a certain function
class_name CallBackValueProvider 
extends ValueProvider

var _fr :FuncRef

func _init(instance :Object, func_name :String):
	_fr = funcref(instance, func_name);
	if not _fr.is_valid():
		push_error("Can't find function '%s' on instance %s" % [func_name, instance])
	
func get_value():
	return _fr.call_func() if _fr.is_valid() else null

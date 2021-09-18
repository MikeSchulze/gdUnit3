# a value provider unsing a callback to get `next` value from a certain function
class_name CallBackValueProvider 
extends ValueProvider

var _fr :FuncRef
var _args :Array

func _init(instance :Object, func_name :String, args :Array = Array(), force_error :=true):
	_fr = funcref(instance, func_name);
	_args = args
	if force_error and not _fr.is_valid():
		push_error("Can't find function '%s' on instance %s" % [func_name, instance])
	
func get_value():
	if not _fr.is_valid():
		return null
	return _fr.call_func() if _args.empty() else _fr.call_funcv(_args)

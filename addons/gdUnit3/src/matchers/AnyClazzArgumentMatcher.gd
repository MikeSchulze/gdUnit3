class_name AnyClazzArgumentMatcher 
extends GdUnitArgumentMatcher
	
var _clazz

func _init(clazz :Object):
	_clazz = clazz

func is_match(value) -> bool:
	if is_instance_valid(value) and GdObjects.is_script(_clazz):
		return value.get_script() == _clazz
	return GdObjects.is_instanceof(value, _clazz)

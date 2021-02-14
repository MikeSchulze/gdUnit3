class_name AnyClazzArgumentMatcher 
extends GdUnitArgumentMatcher
	
var _clazz

func _init(clazz :Object):
	_clazz = clazz

func is_match(value) -> bool:
	return GdObjects.is_instanceof(value, _clazz)

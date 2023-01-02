class_name EqualsArgumentMatcher 
extends GdUnitArgumentMatcher

var _current

func _init(current):
	_current = current

func is_match(value) -> bool:
	# test case sensitive
	return GdObjects.equals(_current, value, true, true)

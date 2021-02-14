class_name AnyStringArgumentMatcher
extends GdUnitArgumentMatcher

func is_match(value) -> bool:
	return typeof(value) == TYPE_STRING

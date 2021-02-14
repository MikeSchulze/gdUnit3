class_name AnyIntArgumentMatcher
extends GdUnitArgumentMatcher

func is_match(value) -> bool:
	return typeof(value) == TYPE_INT

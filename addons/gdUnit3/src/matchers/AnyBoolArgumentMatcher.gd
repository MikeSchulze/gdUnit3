class_name AnyBoolArgumentMatcher
extends GdUnitArgumentMatcher

func is_match(value) -> bool:
	return typeof(value) == TYPE_BOOL

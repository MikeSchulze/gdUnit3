class_name AnyColorArgumentMatcher
extends GdUnitArgumentMatcher

func is_match(value) -> bool:
	return typeof(value) == TYPE_COLOR

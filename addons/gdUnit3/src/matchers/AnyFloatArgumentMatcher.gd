class_name AnyFloatArgumentMatcher
extends GdUnitArgumentMatcher

func is_match(value) -> bool:
	return typeof(value) == TYPE_REAL

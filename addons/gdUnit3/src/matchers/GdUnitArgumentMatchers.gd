class_name GdUnitArgumentMatchers
extends Reference

const TYPE_ANY = TYPE_MAX + 100
const _instances = Dictionary()


func _init():
	for build_in_type in GdObjects.all_types():
		_instances[build_in_type] = AnyBuildInTypeArgumentMatcher.new(build_in_type)
	_instances[TYPE_ANY] = AnyArgumentMatcher.new()

static func to_matcher(arguments :Array) -> ChainedArgumentMatcher:
	var matchers := Array()
	for arg in arguments:
		# argument is already a matcher
		if arg is GdUnitArgumentMatcher:
			matchers.append(arg)
		else:
			# pass argument into equals matcher
			matchers.append(EqualsArgumentMatcher.new(arg))
	return ChainedArgumentMatcher.new(matchers)

static func any() -> GdUnitArgumentMatcher:
	return _instances[TYPE_ANY]

static func by_type(type :int) -> GdUnitArgumentMatcher:
	return _instances[type]

static func any_class(clazz) -> GdUnitArgumentMatcher:
	return AnyClazzArgumentMatcher.new(clazz)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_instances.clear()

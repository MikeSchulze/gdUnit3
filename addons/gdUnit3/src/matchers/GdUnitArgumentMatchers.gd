class_name GdUnitArgumentMatchers
extends Reference

const TYPE_ANY = TYPE_MAX + 100
const _instances = Dictionary()


func _init():
	_instances[TYPE_BOOL] = AnyBoolArgumentMatcher.new()
	_instances[TYPE_INT] = AnyIntArgumentMatcher.new()
	_instances[TYPE_REAL] = AnyFloatArgumentMatcher.new()
	_instances[TYPE_STRING] = AnyStringArgumentMatcher.new()
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

static func any_bool() -> GdUnitArgumentMatcher:
	return _instances[TYPE_BOOL]

static func any_int() -> GdUnitArgumentMatcher:
	return _instances[TYPE_INT]

static func any_float() -> GdUnitArgumentMatcher:
	return _instances[TYPE_REAL]

static func any_string() -> GdUnitArgumentMatcher:
	return _instances[TYPE_STRING] 

static func any_class(clazz) -> GdUnitArgumentMatcher:
	return AnyClazzArgumentMatcher.new(clazz)

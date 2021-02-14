class_name CustomNodeTestClass
extends Node

const STATIC_FUNC_RETURN_VALUE = "i'm a static function"

enum {
	ENUM_A,
	ENUM_B
}


# added a custom static func for mock testing
static func static_test() -> String:
	return STATIC_FUNC_RETURN_VALUE

static func static_test_void() -> void:
	pass

func get_value( type := ENUM_A) -> int:
	match type:
		ENUM_A:
			return 0
		ENUM_B:
			return 1
	return -1

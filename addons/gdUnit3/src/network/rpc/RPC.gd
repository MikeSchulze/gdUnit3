class_name RPC
extends Reference

func serialize() -> String:
	return JSON.print(inst2dict(self))

# using untyped version see comments below
static func deserialize(json :String):
	var result: = JSON.parse(json)
	if not typeof(result.result) == TYPE_DICTIONARY:
		push_error("Can't deserialize JSON, error at line %d: %s \n json:%s" % [result.error_line, result.error_string, json])
		return null
	return dict2inst(result.result)

# this results in orpan node, for more details https://github.com/godotengine/godot/issues/50069
#func deserialize2(data :Dictionary) -> RPC:
#	return  dict2inst(data) as RPC

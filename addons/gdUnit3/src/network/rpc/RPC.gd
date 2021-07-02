class_name RPC
extends Reference

func serialize() -> Dictionary:
	return inst2dict(self)

# using untyped version see comments below
static func deserialize(data :Dictionary):
	return dict2inst(data)

# this results in orpan node, for more details https://github.com/godotengine/godot/issues/50069
#func deserialize2(data :Dictionary) -> RPC:
#	return  dict2inst(data) as RPC

class_name RPC
extends Reference

func serialize() -> Dictionary:
	return inst2dict(self)

static func deserialize(data :Dictionary):
	return dict2inst(data)

# this results in orpan node, create a Godot issue for this
#func deserialize2(data :Dictionary) -> RPC:
#	return  dict2inst(data) as RPC

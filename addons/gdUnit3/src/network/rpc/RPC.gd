class_name RPC
extends Reference

func serialize() -> Dictionary:
	return inst2dict(self)

static func deserialize(data :Dictionary) -> RPC:
	return dict2inst(data) as RPC

class_name RPCGdUnitEvent
extends RPC

var _event :Dictionary

static func of(event :GdUnitEvent) -> RPCGdUnitEvent:
	var rpc = load("res://addons/gdUnit3/src/network/rpc/RPCGdUnitEvent.gd").new()
	rpc._event = event.serialize()
	return rpc

func event() -> GdUnitEvent:
	return GdUnitEvent.new().deserialize(_event)

func to_string():
	return "RPCGdUnitEvent: " + str(_event)

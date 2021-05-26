class_name RPCGdUnitTestSuite
extends RPC

var _data :Dictionary

static func of(test_suite :GdUnitTestSuite) -> RPCGdUnitTestSuite:
	var rpc = load("res://addons/gdUnit3/src/network/rpc/RPCGdUnitTestSuite.gd").new()
	rpc._data = GdSerde.serialize_test_suite(test_suite)
	return rpc

func data() -> GdUnitTestSuite:
	return GdSerde.deserialize_test_suite(_data)

func to_string():
	return "RPCGdUnitTestSuite: " + str(_data)

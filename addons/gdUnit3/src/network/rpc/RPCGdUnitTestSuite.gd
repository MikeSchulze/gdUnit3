class_name RPCGdUnitTestSuite
extends RPC

var _data :Dictionary

static func of(test_suite :GdUnitTestSuite) -> RPCGdUnitTestSuite:
	var rpc = load("res://addons/gdUnit3/src/network/rpc/RPCGdUnitTestSuite.gd").new()
	rpc._data = GdUnitTestSuiteDto.new().serialize(test_suite)
	return rpc

func dto() -> GdUnitResourceDto:
	return GdUnitTestSuiteDto.new().deserialize(_data)

func to_string():
	return "RPCGdUnitTestSuite: " + str(_data)

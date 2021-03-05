class_name GdUnitReportSummary
extends Reference


var _testsiutes := 0
var _tests := 0
var _errors := 0
var _orphans := 0
var _duration := ""


func _init(testsuites :int, tests :int):
	_testsiutes = testsuites
	_tests = tests

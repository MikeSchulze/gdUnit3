class_name GdUnitTestSuiteReport
extends GdUnitReportSummary


var _name :String
var _resource_path :String


func _init(resource_path :String, name :String, tests :int).(0, tests):
	_resource_path = resource_path
	_name = name

func name() -> String:
	return _name

func path() -> String:
	return _resource_path.get_base_dir().replace("res://", "")

func update(failures :int, errors :int, orphans :int) -> void:
	_failure_count = failures
	_error_count = errors
	_orphan_count = orphans
	stop_timer()

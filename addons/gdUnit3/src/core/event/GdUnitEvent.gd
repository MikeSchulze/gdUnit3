class_name GdUnitEvent
extends Resource


const WARNINGS = "warnings"
const FAILED = "failed"
const ERRORS = "errors"
const SKIPPED = "skipped"
const ELAPSED_TIME = "elapsed_time"
const ORPHAN_NODES = "orphan_nodes"
const ERROR_COUNT = "error_count"
const FAILED_COUNT = "failed_count"
const SKIPPED_COUNT = "skipped_count"

enum  {
	INIT,
	STOP,
	TESTSUITE_BEFORE,
	TESTSUITE_AFTER,
	TESTCASE_BEFORE,
	TESTCASE_AFTER,
}

var _event_type
var _resource_path :String
var _suite_name :String
var _test_name :String
var _total_count :int = 0
var _statisics := Dictionary()
var _reports := Array()

func suite_before(resource_path :String, suite_name :String, total_count) -> GdUnitEvent:
	_event_type = TESTSUITE_BEFORE
	_resource_path = resource_path
	_suite_name = suite_name
	_test_name = "before"
	_total_count = total_count
	return self

func suite_after(resource_path :String, suite_name :String, statisics :Dictionary = {}, reports :Array = []) -> GdUnitEvent:
	_event_type = TESTSUITE_AFTER
	_resource_path = resource_path
	_suite_name  = suite_name
	_test_name = "after"
	_statisics = statisics
	_reports = reports
	return self

func test_before(resource_path :String, suite_name:String, test_name:String) -> GdUnitEvent:
	_event_type = TESTCASE_BEFORE
	_resource_path = resource_path
	_suite_name  = suite_name
	_test_name = test_name
	return self

func test_after(resource_path :String, suite_name :String, test_name :String, statisics :Dictionary = {}, reports :Array = []) -> GdUnitEvent:
	_event_type = TESTCASE_AFTER
	_resource_path = resource_path
	_suite_name  = suite_name
	_test_name = test_name
	_statisics = statisics
	_reports = reports
	return self

func type():
	return _event_type

func suite_name() -> String:
	return _suite_name

func test_name() -> String:
	return _test_name

func elapsed_time() -> int:
	return _statisics.get(ELAPSED_TIME, 0)

func orphan_nodes() -> int:
	return  _statisics.get(ORPHAN_NODES, 0)

func statistic(type :String) -> int:
	return _statisics.get(type, 0)

func total_count() -> int:
	return _total_count

func error_count() -> int:
	return _statisics.get(ERROR_COUNT, 0)
	
func failed_count() -> int:
	return _statisics.get(FAILED_COUNT, 0)
	
func skipped_count() -> int:
	return _statisics.get(SKIPPED_COUNT, 0)

func resource_path() -> String:
	return _resource_path

func is_success() -> bool:
	return not is_warning() and not is_failed() and not is_error()

func is_warning() -> bool:
	return _statisics.get(WARNINGS, false)

func is_failed() -> bool:
	return _statisics.get(FAILED, false)

func is_error() -> bool:
	return _statisics.get(ERRORS, false)

func is_skipped() -> bool:
	return _statisics.get(SKIPPED, false)

func reports() -> Array:
	return _reports

func _to_string():
	return "Event: %d %s:%s, %s, %s" % [_event_type, _suite_name, _test_name, _statisics, _reports]

func serialize() -> Dictionary:
	var serialized := {
		"type"         : _event_type,
		"resource_path": _resource_path,
		"suite_name"   : _suite_name,
		"test_name"    : _test_name,
		"total_count"  : _total_count,
		"statisics"    : _statisics
	}
	serialized["reports"] = _serialize_TestReports()
	return serialized

func deserialize(serialized:Dictionary) -> GdUnitEvent:
	_event_type    = serialized["type"]
	_resource_path = serialized["resource_path"]
	_suite_name    = serialized["suite_name"]
	_test_name     = serialized["test_name"]
	_total_count   = serialized["total_count"]
	_statisics     = serialized["statisics"]
	_reports       = _deserialize_reports(serialized["reports"])
	return self

func _serialize_TestReports() -> Array:
	var serialized_reports := Array()
	for report in _reports:
		serialized_reports.append(report.serialize())
	return serialized_reports

func _deserialize_reports(reports:Array) -> Array:
	var deserialized_reports := Array()
	for report in reports:
		var test_report := GdUnitReport.new().deserialize(report)
		deserialized_reports.append(test_report)
	return deserialized_reports
	

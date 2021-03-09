class_name GdUnitReportSummary
extends Reference

var _resource_path :String
var _name :String
var _suite_count := 0
var _test_count := 0
var _failure_count := 0
var _error_count := 0
var _orphan_count := 0
var _duration := 0
var _reports:Array = Array()

func name() -> String:
	return _name

func path() -> String:
	return _resource_path.get_base_dir().replace("res://", "")

func suite_count() -> int:
	return _reports.size()

func test_count() -> int:
	var count := _test_count
	for report in _reports:
		count += report.test_count()
	return count

func failure_count() -> int:
	var count := _failure_count
	for report in _reports:
		count += report.failure_count()
	return count

func orphan_count() -> int:
	var count := _orphan_count
	for report in _reports:
		count += report.orphan_count()
	return count

func duration() -> int:
	var count := _duration
	for report in _reports:
		count += report.duration()
	return count

func add_report(report :GdUnitReportSummary) -> void:
	_reports.append(report)

func report_state() -> String:
	return calculate_state(failure_count(), orphan_count())

func succes_rate() -> String:
	return calculate_succes_rate(test_count(), failure_count())

static func calculate_state(failure_count :int, orphan_count :int) -> String:
	if failure_count > 0:
		return "failure"
	if orphan_count > 0:
		return "warning"
	return "success"

static func calculate_succes_rate(test_count :int, failure_count: int) -> String:
	if failure_count == 0:
		return "100%"
	return "%d" % ((test_count-failure_count) * 100 / test_count) + "%"

func create_summary(report_dir :String) -> String:
	return ""

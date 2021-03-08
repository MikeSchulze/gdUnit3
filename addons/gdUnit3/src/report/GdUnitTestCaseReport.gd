class_name GdUnitTestCaseReport
extends Reference


const SUITE_TESTS_REPORT_TEMPLATE = """
								<tr>
									<td class="${report_state}">${testcase_name}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
								</tr>
"""

var _name :String
var _is_failed :bool
var _orphans :int
var _reports :Array
var _duration :int

func _init(test_name :String, is_failed :bool, orphans :int, reports :Array, duration :int):
	_name = test_name
	_is_failed = is_failed
	_orphans = orphans
	_reports = reports
	_duration = duration

func create_summary() -> String:
	return SUITE_TESTS_REPORT_TEMPLATE\
		.replace("${report_state}", report_state())\
		.replace("${testcase_name}", _name)\
		.replace("${orphan_count}", str(_orphans))\
		.replace("${duration}", LocalTime.elapsed(_duration))

func report_state() -> String:
	if _is_failed:
		return "failure"
	if _orphans > 0:
		return "warning"
	return "success"

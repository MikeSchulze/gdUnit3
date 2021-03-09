class_name GdUnitTestCaseReport
extends GdUnitReportSummary

var _failure_reports :Array

func _init(test_name :String, is_failed :bool, orphans :int, failure_reports :Array, duration :int):
	_name = test_name
	_test_count = 1
	_failure_count = is_failed
	_orphan_count = orphans
	_failure_reports = failure_reports
	_duration = duration

func create_record(report_dir :String) -> String:
	return GdUnitHtmlPatterns.TABLE_RECORD_TESTCASE\
		.replace(GdUnitHtmlPatterns.REPORT_STATE, report_state())\
		.replace(GdUnitHtmlPatterns.TESTCASE_NAME, name())\
		.replace(GdUnitHtmlPatterns.ORPHAN_COUNT, str(orphan_count()))\
		.replace(GdUnitHtmlPatterns.DURATION, LocalTime.elapsed(_duration))

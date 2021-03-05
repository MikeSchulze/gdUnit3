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

func failure_report() -> String:
	var html_report := ""
	for r in _failure_reports:
		var report: GdUnitReport = r
		# TODO convert rtf to html
		html_report += convert_rtf_to_text(report._to_string())
	return html_report

func convert_rtf_to_text(bbcode :String) -> String:
	var rtf := RichTextLabel.new()
	rtf.parse_bbcode(bbcode)
	var as_text: = rtf.text
	rtf.free()
	return as_text

func create_record(report_dir :String) -> String:
	return GdUnitHtmlPatterns.TABLE_RECORD_TESTCASE\
		.replace(GdUnitHtmlPatterns.REPORT_STATE, report_state())\
		.replace(GdUnitHtmlPatterns.TESTCASE_NAME, name())\
		.replace(GdUnitHtmlPatterns.ORPHAN_COUNT, str(orphan_count()))\
		.replace(GdUnitHtmlPatterns.DURATION, LocalTime.elapsed(_duration))\
		.replace(GdUnitHtmlPatterns.FAILURE_REPORT, failure_report())

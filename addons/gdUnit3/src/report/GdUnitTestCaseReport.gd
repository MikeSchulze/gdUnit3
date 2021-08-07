class_name GdUnitTestCaseReport
extends GdUnitReportSummary

var _failure_reports :Array

func _init(test_name :String, is_error :bool = false, is_failed :bool = false, orphans :int = 0, skipped :int = 0, failure_reports :Array = [], duration :int = 0):
	_name = test_name
	_test_count = 1
	_error_count = is_error
	_failure_count = is_failed
	_orphan_count = orphans
	_skipped_count = skipped
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
	var converted := PoolStringArray()
	var lines := as_text.split("\n")
	for line in lines:
		converted.append("<p>%s</p>" % line)
	return converted.join("\n")

func create_record(report_dir :String) -> String:
	return GdUnitHtmlPatterns.TABLE_RECORD_TESTCASE\
		.replace(GdUnitHtmlPatterns.REPORT_STATE, report_state())\
		.replace(GdUnitHtmlPatterns.TESTCASE_NAME, name())\
		.replace(GdUnitHtmlPatterns.SKIPPED_COUNT, str(skipped_count()))\
		.replace(GdUnitHtmlPatterns.ORPHAN_COUNT, str(orphan_count()))\
		.replace(GdUnitHtmlPatterns.DURATION, LocalTime.elapsed(_duration))\
		.replace(GdUnitHtmlPatterns.FAILURE_REPORT, failure_report())

func update(report :GdUnitTestCaseReport) -> void:
	_error_count += report.error_count()
	_failure_count += report.failure_count()
	_orphan_count += report.orphan_count()
	_skipped_count += report.skipped_count()
	_failure_reports += report._failure_reports
	_duration += report.duration()

class_name GdUnitHtmlReport
extends GdUnitReportSummary

const REPORT_DIR_PREFIX = "report_"

var _report_path :String
var _iteration :int

func _init(path :String):
	_iteration = GdUnitTools.find_last_path_index(path, REPORT_DIR_PREFIX) + 1
	_report_path = "%s/%s%d" % [path, REPORT_DIR_PREFIX, _iteration]

func add_testsuite_report(suite_report :GdUnitTestSuiteReport):
	_reports.append(suite_report)

func add_testcase_report(suite_name :String, suite_report :GdUnitTestCaseReport) -> void:
	for report in _reports:
		if report.name() == suite_name:
			report.add_report(suite_report)

func update_test_suite_report(suite_name :String, skipped :int, orphans :int, duration :int) -> void:
	for report in _reports:
		if report.name() == suite_name:
			report.set_duration(duration)
			report.set_skipped(skipped)
			report.set_orphans(orphans)

func update_testcase_report(suite_name :String, test_report :GdUnitTestCaseReport):
	for report in _reports:
		if report.name() == suite_name:
			report.update(test_report)

func write() -> String:
	var template := GdUnitHtmlPatterns.load_template("res://addons/gdUnit3/src/report/template/index.html")
	var to_write = GdUnitHtmlPatterns.build(template, self, "")
	to_write = apply_path_reports(_report_path, to_write, _reports)
	to_write = apply_testsuite_reports(_report_path, to_write, _reports)

	# write report
	var index_file := "%s/index.html" % _report_path
	var file := File.new()
	file.open(index_file, File.WRITE)
	file.store_string(to_write)
	file.close()
	GdUnitTools.copy_directory("res://addons/gdUnit3/src/report/template/css/", _report_path + "/css")
	return index_file

func delete_history(max_reports :int) -> int:
	return GdUnitTools.delete_path_index_lower_equals_than(_report_path.get_base_dir(), REPORT_DIR_PREFIX, _iteration-max_reports)

static func apply_path_reports(report_dir :String, template :String, reports :Array) -> String:
	var path_report_mapping := GdUnitByPathReport.sort_reports_by_path(reports)
	var table_records := PoolStringArray()
	var paths := path_report_mapping.keys()
	paths.sort()
	for path in paths:
		var report := GdUnitByPathReport.new(path, path_report_mapping.get(path))
		var report_link :String = report.write(report_dir).replace(report_dir, ".")
		table_records.append(report.create_record(report_link))
	return template.replace(GdUnitHtmlPatterns.TABLE_BY_PATHS, table_records.join("\n"))

static func apply_testsuite_reports(report_dir :String, template :String, reports :Array) -> String:
	var table_records := PoolStringArray()

	for report in reports:
		var report_link :String = report.write(report_dir).replace(report_dir, ".")
		table_records.append(report.create_record(report_link))
	return template.replace(GdUnitHtmlPatterns.TABLE_BY_TESTSUITES, table_records.join("\n"))

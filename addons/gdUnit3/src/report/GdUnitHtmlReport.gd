class_name GdUnitHtmlReport
extends GdUnitReportSummary

func add_testsuite_report(suite_report :GdUnitReportSummary):
	_reports.append(suite_report)

func add_testcase_report(suite_name :String, test_report :GdUnitReportSummary):
	for report in _reports:
		if report.name() == suite_name:
			report.add_report(test_report)

func set_testsuite_duration(suite_name :String, duration :int) -> void:
	for report in _reports:
		if report.name() == suite_name:
			report.set_duration(duration)

func write(report_dir :String) -> String:
	var template := GdUnitHtmlPatterns.load_template("res://addons/gdUnit3/src/report/template/index.html")
	var to_write = GdUnitHtmlPatterns.build(template, self, "")
	to_write = apply_path_reports(report_dir, to_write, _reports)
	to_write = apply_testsuite_reports(report_dir, to_write, _reports)
	
	# write report
	var file := File.new()
	file.open("%s/index.html" % report_dir, File.WRITE)
	file.store_string(to_write)
	file.close()
	
	GdUnitTools.copy_directory("res://addons/gdUnit3/src/report/template/css/", report_dir)
	return "%s/index.html" % report_dir

static func apply_path_reports(report_dir :String, template :String, reports :Array) -> String:
	var path_report_mapping := GdUnitByPathReport.sort_reports_by_path(reports)
	var table_records := PoolStringArray()
	var paths := path_report_mapping.keys()
	paths.sort()
	for path in paths:
		var report := GdUnitByPathReport.new(path, path_report_mapping.get(path))
		var report_link :String = report.write(report_dir)
		table_records.append(report.create_record(report_link))
	return template.replace(GdUnitHtmlPatterns.TABLE_BY_PATHS, table_records.join("\n"))

static func apply_testsuite_reports(report_dir :String, template :String, reports :Array) -> String:
	var table_records := PoolStringArray()
	
	for report in reports:
		var report_link :String = report.write(report_dir)
		table_records.append(report.create_record(report_link))
	return template.replace(GdUnitHtmlPatterns.TABLE_BY_TESTSUITES, table_records.join("\n"))

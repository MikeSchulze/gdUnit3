class_name GdUnitTestSuiteReport
extends GdUnitReportSummary

func _init(resource_path :String, name :String):
	_resource_path = resource_path
	_name = name

func create_record(report_link :String) -> String:
	return GdUnitHtmlPatterns.build(GdUnitHtmlPatterns.TABLE_RECORD_TESTSUITE, self, report_link)

func output_path(report_dir :String) -> String:
	return "%s/test_suites/%s.%s.html" % [report_dir, path().replace("/", "."), name()]

func path_as_link() -> String:
	return "../path/%s.html" % path().replace("/", ".")

func write(report_dir :String) -> String:
	var template := GdUnitHtmlPatterns.load_template("res://addons/gdUnit3/src/report/template/suite_report.html")
	template = GdUnitHtmlPatterns.build(template, self, "")\
		.replace(GdUnitHtmlPatterns.BREADCRUMP_PATH_LINK, path_as_link())
		
	var report_output_path := output_path(report_dir)
	var test_report_table := PoolStringArray()
	for test_report in _reports:
		test_report_table.append(test_report.create_record(report_output_path))
	
	template = template.replace(GdUnitHtmlPatterns.TABLE_BY_TESTCASES, test_report_table.join("\n"))
	
	var dir := report_output_path.get_base_dir()
	var dest_dir := Directory.new()
	if not dest_dir.dir_exists(dir):
		dest_dir.make_dir_recursive(dir)
	
	var file := File.new()
	file.open(report_output_path, File.WRITE)
	file.store_string(template)
	file.close()
	return report_output_path

func set_duration(duration :int) -> void:
	_duration = duration

func duration() -> int:
	return _duration

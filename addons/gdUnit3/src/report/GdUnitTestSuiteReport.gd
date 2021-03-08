class_name GdUnitTestSuiteReport
extends GdUnitReportSummary

const SUITE_REPORT_TEMPLATE = """
								<tr>
									<td><a class="${report_state}" href=${testsuite_report_path}>${testsuite_name}</a></td>
									<td>${test_count}</td>
									<td>${failure_count}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="success">${success_percent}</td>
								</tr>
"""

const PATTERN_TESTSUITE_NAME = "${testsuite_name}"
const PATTERN_TESTSUITE_REPORT_PATH = "${testsuite_report_path}"
const PATTERN_TESTCASE_REPORT_TABLE = "${testcase_report_table}"

var _name :String
var _resource_path :String
var _test_reports :Array = Array()


func _init(resource_path :String, name :String, tests :int).(0, tests):
	_resource_path = resource_path
	_name = name

func name() -> String:
	return _name

func path() -> String:
	return _resource_path.get_base_dir().replace("res://", "")

func update(failures :int, errors :int, orphans :int, duration :int) -> void:
	_failure_count = failures
	_error_count = errors
	_orphan_count = orphans
	_duration = duration

func add_test_report(test_name :String, is_failed :bool, orphans :int, reports :Array, duration :int) -> void:
	_test_reports.append(GdUnitTestCaseReport.new(test_name, is_failed, orphans, reports, duration))

func create_summary(report_dir :String) -> String:
	var report_output_path := "%s/test_suites/%s.%s.html" % [report_dir, path().replace("/", "."), name()]
	prints("write suite report", report_output_path)
	write_html_suite_report(report_output_path)
	
	return fill_summary(SUITE_REPORT_TEMPLATE, self)\
		.replace("${report_state}", report_state())\
		.replace(PATTERN_TESTSUITE_NAME, name())\
		.replace(PATTERN_PATH, path())\
		.replace(PATTERN_TESTSUITE_REPORT_PATH, report_output_path)


func report_path() -> String:
	return "%s.%s.html" % [path(), name()]
	

func write_html_folder_report(report_dir :String) -> String:
	var template := load_template("res://addons/gdUnit3/src/report/template/folder_report.html")
	
	return ""

func write_html_suite_report(report_output_path :String) -> String:
	var template := load_template("res://addons/gdUnit3/src/report/template/suite_report.html")
	
	template = fill_summary(template, self)\
		.replace(PATTERN_PATH, path())\
		.replace(PATTERN_TESTSUITE_NAME, name())
		
	var test_report_table := PoolStringArray()
	for test_report in _test_reports:
		test_report_table.append(test_report.create_summary())
	
	template = template.replace(PATTERN_TESTCASE_REPORT_TABLE, test_report_table.join("\n"))
	
	var dir := report_output_path.get_base_dir()
	var dest_dir := Directory.new()
	if not dest_dir.dir_exists(dir):
		dest_dir.make_dir_recursive(dir)
	

	var file := File.new()
	file.open(report_output_path, File.WRITE)
	file.store_string(template)
	file.close()
	
	
	return report_output_path
	

func report_state() -> String:
	if _failure_count:
		return "failure"
	if _orphan_count > 0:
		return "warning"
	return "success"

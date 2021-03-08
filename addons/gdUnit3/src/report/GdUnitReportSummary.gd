class_name GdUnitReportSummary
extends Reference

const FOLDER_REPORT_TEMPLATE = """
								<tr>
									<td><a class="success" href="folders/${path}.html">${path}</a></td>
									<td>${test_count}</td>
									<td>${failure_count}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="success">${success_percent}</td>
								</tr>
"""
const REPORT_BY_FOLDER = "${testsuite_report_by_folders}"


const REPORT_BY_SUITES = "${testsuite_report_by_suites}"

# the report state success, error, warning
const PATTERN_REPORT_STATE = "${report_state}"
const PATTERN_PATH = "${path}"
const PATTERN_TESTSUITE_COUNT = "${suite_count}"
const PATTERN_TEST_COUNT = "${test_count}"
const PATTERN_FAILURE_COUNT = "${failure_count}"
const PATTERN_ORPHAN_COUNT = "${orphan_count}"
const PATTERN_DURATION = "${duration}"
const PATTERN_SUCCESS_PERCENT = "${success_percent}"


var _suite_count := 0
var _test_count := 0
var _failure_count := 0
var _error_count := 0
var _orphan_count := 0
var _duration := 0
var _reports:Dictionary = Dictionary()

func _init(testsuites :int, tests :int):
	_suite_count = testsuites
	_test_count = tests
	_duration = OS.get_system_time_msecs()

func stop_timer() -> void:
	_duration = OS.get_system_time_msecs() - _duration

func suite_count() -> int:
	return _suite_count

func test_count() -> int:
	return _test_count 

func failure_count() -> int:
	return _failure_count

func orphan_count() -> int:
	return _orphan_count

func duration() -> int:
	return _duration

func report_state() -> String:
	if _failure_count > 0:
		return "failure"
	
	return "success"

func add_report(report) -> void:
	_reports[report.name()] = report

func add_testsuite_summary(suite_name :String, failures :int, errors :int, orphans :int, duration :int):
	var suite_report = _reports[suite_name]
	suite_report.update(failures, errors, orphans, duration)

func add_testcase_report(suite_name :String, test_name :String, is_failed :bool, orphans :int, reports :Array, duration :int):
	var suite_report = _reports[suite_name]
	suite_report.add_test_report(test_name, is_failed, orphans, reports, duration)


func write_html_report(report_dir :String) -> String:
	var template := load_template("res://addons/gdUnit3/src/report/template/index.html")
	var to_write = fill_summary(template, self)
	to_write = fill_folder_reports(to_write)
	to_write = fill_suite_reports(to_write, report_dir)

	
	# write report
	var file := File.new()
	file.open("%s/index.html" % report_dir, File.WRITE)
	file.store_string(to_write)
	file.close()
	
	GdUnitTools.copy_directory("res://addons/gdUnit3/src/report/template/css/", report_dir)
	return "%s/index.html" % report_dir


func fill_summary(template :String, report :GdUnitReportSummary) -> String:
	return template\
		.replace(PATTERN_TESTSUITE_COUNT, str(report.suite_count()))\
		.replace(PATTERN_TEST_COUNT, str(report.test_count()))\
		.replace(PATTERN_FAILURE_COUNT, str(report.failure_count()))\
		.replace(PATTERN_ORPHAN_COUNT, str(report.orphan_count()))\
		.replace(PATTERN_DURATION, LocalTime.elapsed(report.duration()))\
		.replace(PATTERN_SUCCESS_PERCENT, calculate_succes_rate())\
		.replace(PATTERN_REPORT_STATE, report_state())
		


func fill_folder_reports(template :String) -> String:
	var report_rows := PoolStringArray()
	var by_paths := merged_report_by_path(_reports.values())
	
	for path in by_paths.keys():
		var reports :Array = by_paths.get(path)
		var test_count := 0
		var failure_count := 0
		var orphan_count := 0
		var duration := 0
		for report in reports:
			test_count += report.test_count()
			failure_count += report.failure_count()
			orphan_count += report.orphan_count()
			duration += report.duration()
		
		var folder_report := FOLDER_REPORT_TEMPLATE\
			.replace(PATTERN_PATH, path)\
			.replace(PATTERN_TEST_COUNT, str(test_count))\
			.replace(PATTERN_FAILURE_COUNT, str(failure_count))\
			.replace(PATTERN_ORPHAN_COUNT, str(orphan_count))\
			.replace(PATTERN_DURATION, LocalTime.elapsed(duration))\
			.replace(PATTERN_SUCCESS_PERCENT, calculate_succes_rate())
		
		report_rows.append(folder_report)
	by_paths.clear()
	return template.replace(REPORT_BY_FOLDER, report_rows.join("\n"))
	
	
	

func fill_suite_reports(template :String, report_dir :String) -> String:
	var report_rows := PoolStringArray()
	for report in _reports.values():
		report_rows.append(report.create_summary(report_dir))
		
	return template.replace(REPORT_BY_SUITES, report_rows.join("\n"))



static func merged_report_by_path(reports :Array) -> Dictionary:
	
	var by_path := Dictionary()
	for report in reports:
		var suite_path :String = report.path()
		var suite_report :Array = by_path.get(suite_path, Array())
		suite_report.append(report)
		by_path[suite_path] = suite_report
	return by_path



func calculate_succes_rate() -> String:
	return "100%"


func load_template(template_name :String) -> String:
	var file := File.new()
	file.open(template_name, File.READ)
	var template := file.get_as_text()
	file.close()
	return template

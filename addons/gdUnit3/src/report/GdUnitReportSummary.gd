class_name GdUnitReportSummary
extends Reference

const FOLDER_SUMMARY_TEMPLATE = """
	<tr>
		<td><a class="success" href="folders/${path}.html">${path}</a></td>
		<td>${test_count}</td>
		<td>${failure_count}</td>
		<td>${orphan_count}</td>
		<td>${duration}</td>
		<td class="success">${success_percent}</td>
	</tr>
"""

const PATTERN_PATH = "${path}"
const PATTERN_TESTSUITE_COUNT = "${suite_count}"
const PATTERN_TEST_COUNT = "${test_count}"
const PATTERN_FAILURE_COUNT = "${failure_count}"
const PATTERN_ORPHAN_COUNT = "${orphan_count}"
const PATTERN_DURATION = "${duration}"
const PATTERN_SUCCESS_PERCENT = "${success_percent}"
const REPORT_BY_FOLDER = "${testsuite_report_by_folders}"

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

func add_report(report) -> void:
	_reports[report.name()] = report

func set_summary(name :String, failures :int, errors :int, orphans :int):
	var report = _reports[name]
	report.update(failures, errors, orphans)


func write_html_report(report_dir :String) :
	var template := load_template()
	var to_write = fill_summary(template)
	to_write = fill_list_folder_report(to_write)
	#to_write = fill_list_suite_report(to_write)

	
	# write report
	var file := File.new()
	file.open("%s/index.html" % report_dir, File.WRITE)
	file.store_string(to_write)
	file.close()
	
	GdUnitTools.copy_directory("res://addons/gdUnit3/src/report/template/css/", report_dir)
	
	prints("Open Report at:", "%s/index.html" % report_dir)


func fill_summary(template :String) -> String:
	return template\
		.replace(PATTERN_PATH, str(test_count()))\
		.replace(PATTERN_TESTSUITE_COUNT, str(suite_count()))\
		.replace(PATTERN_TEST_COUNT, str(test_count()))\
		.replace(PATTERN_FAILURE_COUNT, str(failure_count()))\
		.replace(PATTERN_ORPHAN_COUNT, str(orphan_count()))\
		.replace(PATTERN_DURATION, str(_duration))\
		.replace(PATTERN_SUCCESS_PERCENT, calculate_succes_rate())


func to_html(path :String) -> String:
	return FOLDER_SUMMARY_TEMPLATE\
		.replace(PATTERN_PATH, path)\
		.replace(PATTERN_TEST_COUNT, str(test_count()))\
		.replace(PATTERN_FAILURE_COUNT, str(failure_count()))\
		.replace(PATTERN_ORPHAN_COUNT, str(orphan_count()))\
		.replace(PATTERN_DURATION, str(_duration))


func fill_list_folder_report(template :String) -> String:
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
		
		var row := FOLDER_SUMMARY_TEMPLATE\
			.replace(PATTERN_PATH, path)\
			.replace(PATTERN_TEST_COUNT, str(test_count))\
			.replace(PATTERN_FAILURE_COUNT, str(failure_count))\
			.replace(PATTERN_ORPHAN_COUNT, str(orphan_count))\
			.replace(PATTERN_DURATION, LocalTime.elapsed(duration))
		
		report_rows.append(row)
	by_paths.clear()
	return template.replace(REPORT_BY_FOLDER, report_rows.join("\n"))
	
	
	

func fill_list_suite_report(template :String) -> String:
	return template



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

func load_template() -> String:
	var file := File.new()
	file.open("res://addons/gdUnit3/src/report/template/index.html", File.READ)
	var template := file.get_as_text()
	file.close()
	return template

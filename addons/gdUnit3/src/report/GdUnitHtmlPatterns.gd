class_name GdUnitHtmlPatterns
extends Reference

const TABLE_RECORD_TESTSUITE = """
								<tr>
									<td><a class="${report_state}" href=${report_link}>${testsuite_name}</a></td>
									<td>${test_count}</td>
									<td>${failure_count}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="${report_state}">${success_percent}</td>
								</tr>
"""

const TABLE_RECORD_PATH = """
								<tr>
									<td><a class="${report_state}" href="${report_link}">${path}</a></td>
									<td>${test_count}</td>
									<td>${failure_count}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
									<td class="${report_state}">${success_percent}</td>
								</tr>
"""

const TABLE_RECORD_TESTCASE = """
								<tr>
									<td class="${report_state}">${testcase_name}</td>
									<td>${orphan_count}</td>
									<td>${duration}</td>
								</tr>
"""

const TABLE_BY_PATHS = "${report_table_paths}"
const TABLE_BY_TESTSUITES = "${report_table_testsuites}"
const TABLE_BY_TESTCASES = "${report_table_tests}"

# the report state success, error, warning
const REPORT_STATE = "${report_state}"
const PATH = "${path}"
const TESTSUITE_COUNT = "${suite_count}"
const TESTCASE_COUNT = "${test_count}"
const FAILURE_COUNT = "${failure_count}"
const ORPHAN_COUNT = "${orphan_count}"
const DURATION = "${duration}"
const SUCCESS_PERCENT = "${success_percent}"

const TESTSUITE_NAME = "${testsuite_name}"
const TESTCASE_NAME = "${testcase_name}"
const REPORT_LINK = "${report_link}"
const BREADCRUMP_PATH_LINK = "${breadcrumb_path_link}"


static func build(template :String, report :GdUnitReportSummary, report_link :String) -> String:
	return template\
		.replace(PATH, report.path())\
		.replace(TESTSUITE_NAME, report.name())\
		.replace(TESTSUITE_COUNT, str(report.suite_count()))\
		.replace(TESTCASE_COUNT, str(report.test_count()))\
		.replace(FAILURE_COUNT, str(report.failure_count()))\
		.replace(ORPHAN_COUNT, str(report.orphan_count()))\
		.replace(DURATION, LocalTime.elapsed(report.duration()))\
		.replace(SUCCESS_PERCENT, report.calculate_succes_rate(report.test_count(), report.failure_count()))\
		.replace(REPORT_STATE, report.report_state())\
		.replace(REPORT_LINK, report_link)

static func load_template(template_name :String) -> String:
	var file := File.new()
	file.open(template_name, File.READ)
	var template := file.get_as_text()
	file.close()
	return template
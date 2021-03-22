class_name GdAssertReports
extends Reference

const LAST_ERROR = "last_assert_error_message"

# if a test success but we expect to fail map to an error
static func report_success(gd_assert :GdUnitAssert) -> GdUnitAssert:
	Engine.remove_meta(LAST_ERROR)
	if not gd_assert._expect_fail || gd_assert._is_failed:
		return gd_assert
	send_report(GdAssertMessages._error("Expecting to fail!"), gd_assert._get_line_number(), GdUnitReport.SUCCESS)
	return gd_assert


static func report_error(message:String, gd_assert :GdUnitAssert, line_number :int) -> GdUnitAssert:
	if gd_assert != null:
		gd_assert._is_failed = true
		gd_assert._current_error_message = message
		# use this kind of hack to enable validate error message for expected failure testing
		Engine.set_meta(LAST_ERROR, message)
		# if we expect to fail we handle as success test
		if gd_assert._expect_fail:
			return gd_assert
	send_report(message, line_number, GdUnitReport.ERROR)
	return gd_assert


static func send_report(message :String, line_number :int, reportType = GdUnitReport.ERROR):
	# temporary workarround
	var eventHandler:SignalHandler = GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)
	eventHandler.send_test_report(GdUnitReport.new().create(reportType, line_number, message))

tool
class_name GdUnitSettings
extends Reference

const MAIN_CATEGORY = "gdunit3"
# Common Settings
const COMMON_SETTINGS = MAIN_CATEGORY + "/settings"

const UPDATE_NOTIFICATION_ENABLED = COMMON_SETTINGS + "/update_notification_enabled"

const SERVER_TIMEOUT = COMMON_SETTINGS + "/server_connection_timeout_minutes"
const TEST_TIMEOUT = COMMON_SETTINGS + "/test_timeout_seconds"

# Report Setiings
const REPORT_SETTINGS = MAIN_CATEGORY + "/report"
const REPORT_ERROR_NOTIFICATIONS = REPORT_SETTINGS + "/error_notification"
const REPORT_ORPHANS  = REPORT_SETTINGS + "/verbose_orphans"
const REPORT_ASSERT_WARNINGS = REPORT_SETTINGS + "/assert/verbose_warnings"
const REPORT_ASSERT_ERRORS   = REPORT_SETTINGS + "/assert/verbose_errors"

# Godot stdout/logging settings
const CATEGORY_LOGGING := "logging/file_logging/"
const STDOUT_ENABLE_TO_FILE = CATEGORY_LOGGING + "enable_file_logging"
const STDOUT_WITE_TO_FILE = CATEGORY_LOGGING + "log_path"


# defaults
# server connection timeout in minutes
const DEFAULT_SERVER_TIMEOUT := 30
# test case runtime timeout in seconds
const DEFAULT_TEST_TIMEOUT := 60*5

static func setup():
	create_property_if_need(UPDATE_NOTIFICATION_ENABLED, true)
	create_property_if_need(SERVER_TIMEOUT, DEFAULT_SERVER_TIMEOUT)
	create_property_if_need(TEST_TIMEOUT, DEFAULT_TEST_TIMEOUT)
	create_property_if_need(REPORT_ERROR_NOTIFICATIONS, false)
	create_property_if_need(REPORT_ORPHANS, true)
	create_property_if_need(REPORT_ASSERT_ERRORS, true)
	create_property_if_need(REPORT_ASSERT_WARNINGS, true)

static func create_property_if_need(name :String, default) -> void:
	if not ProjectSettings.has_setting(name):
		prints("GdUnit3: Set inital settings '%s' to '%s'." % [name, str(default)])
		ProjectSettings.set_setting(name, default)
		ProjectSettings.set_initial_value(name, default)

static func get_setting(name :String, default) :
	if ProjectSettings.has_setting(name):
		return ProjectSettings.get_setting(name)
	return default

static func is_update_notification_enabled() -> bool:
	if ProjectSettings.has_setting(UPDATE_NOTIFICATION_ENABLED):
		return ProjectSettings.get_setting(UPDATE_NOTIFICATION_ENABLED)
	return false

static func set_update_notification(enable :bool) -> void:
	ProjectSettings.set_setting(UPDATE_NOTIFICATION_ENABLED, enable)
	ProjectSettings.save()

static func is_report_push_errors() -> bool:
	if ProjectSettings.has_setting(REPORT_ERROR_NOTIFICATIONS):
		return ProjectSettings.get_setting(REPORT_ERROR_NOTIFICATIONS)
	return false

static func is_log_enabled() -> bool:
	return ProjectSettings.get_setting(STDOUT_ENABLE_TO_FILE)

static func get_log_path() -> String:
	return ProjectSettings.get_setting(STDOUT_WITE_TO_FILE)

static func set_log_path(path :String) -> void:
	ProjectSettings.set_setting(STDOUT_ENABLE_TO_FILE, true)
	ProjectSettings.set_setting(STDOUT_WITE_TO_FILE, path)
	ProjectSettings.save()

# the configured server connection timeout in ms
static func server_timeout() -> int:
	return get_setting(SERVER_TIMEOUT, DEFAULT_SERVER_TIMEOUT) * 60 * 1000

# the configured test case timeout in ms
static func test_timeout() -> int:
	return get_setting(TEST_TIMEOUT, DEFAULT_TEST_TIMEOUT) * 1000

static func is_verbose_assert_warnings() -> bool:
	return get_setting(REPORT_ASSERT_WARNINGS, true)

static func is_verbose_assert_errors() -> bool:
	return get_setting(REPORT_ASSERT_ERRORS, true)

static func is_verbose_orphans() -> bool:
	return get_setting(REPORT_ORPHANS, true)

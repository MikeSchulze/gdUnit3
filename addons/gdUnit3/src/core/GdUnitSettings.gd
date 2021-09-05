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


# GdUnit Templates
const TEMPLATES = MAIN_CATEGORY + "/templates"
const TEMPLATES_TS = TEMPLATES + "/testsuite"
const TEMPLATE_TS_GD = TEMPLATES_TS + "/GDScript"
const TEMPLATE_TS_CS = TEMPLATES_TS + "/CSharpScript"

# defaults
# server connection timeout in minutes
const DEFAULT_SERVER_TIMEOUT :int = 30
# test case runtime timeout in seconds
const DEFAULT_TEST_TIMEOUT :int = 60*5


const DEFAULT_TEMP_TS_GD = """# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name ${class_name}
extends GdUnitTestSuite

# TestSuite generated from
const __source = '${source_path}'
"""

static func setup():
	create_property_if_need(UPDATE_NOTIFICATION_ENABLED, true, "Enables/Disables the update notification on startup.")
	create_property_if_need(SERVER_TIMEOUT, DEFAULT_SERVER_TIMEOUT, "Sets the server connection timeout in minutes.")
	create_property_if_need(TEST_TIMEOUT, DEFAULT_TEST_TIMEOUT, "Sets the test case runtime timeout in seconds.")
	create_property_if_need(REPORT_ERROR_NOTIFICATIONS, false, "Current not supported!")
	create_property_if_need(REPORT_ORPHANS, true, "Enables/Disables orphan reporting.")
	create_property_if_need(REPORT_ASSERT_ERRORS, true, "Enables/Disables error reporting on asserts.")
	create_property_if_need(REPORT_ASSERT_WARNINGS, true, "Enables/Disables warning reporting on asserts")
	create_property_if_need(TEMPLATE_TS_GD, DEFAULT_TEMP_TS_GD, "Defines the test suite template")

static func create_property_if_need(name :String, default, help :="") -> void:
	if not ProjectSettings.has_setting(name):
		prints("GdUnit3: Set inital settings '%s' to '%s'." % [name, str(default)])
		ProjectSettings.set_setting(name, default)
		
	ProjectSettings.set_initial_value(name, default)
	var info = {
			"name": name,
			"type": typeof(default),
			"hint": PROPERTY_HINT_LENGTH,
			"hint_string": help,
		}
	ProjectSettings.add_property_info(info)

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

static func list_settings(category :String) -> Array:
	var settings := Array()
	for property in ProjectSettings.get_property_list():
		var property_name = property["name"]
		if property_name.begins_with(category):
			var value = ProjectSettings.get_setting(property_name)
			var default = ProjectSettings.property_get_revert(property_name)
			settings.append(GdUnitProperty.new(property_name, property["type"], value, default, property["hint_string"]))
	return settings

static func update_property(property :GdUnitProperty) -> void:
	ProjectSettings.set_setting(property.name(), property.value())
	ProjectSettings.save()

static func reset_property(property :GdUnitProperty) -> void:
	ProjectSettings.set_setting(property.name(), property.default())
	ProjectSettings.save()

static func save_property(name :String, value) -> void:
	ProjectSettings.set_setting(name, value)
	ProjectSettings.save()

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
const DEFAULT_SERVER_TIMEOUT :int = 30
# test case runtime timeout in seconds
const DEFAULT_TEST_TIMEOUT :int = 60*5


class GdUnitProperty:
	var _name :String
	var _help :String
	var _type :int
	var _value
	var _default
	
	func _init(name :String, type :int, value, default_value, help :="" ):
		_name = name
		_type = type
		_value = value
		_default = default_value
		_help = help
	
	func name() -> String:
		return _name
	
	func type() -> int:
		return _type
	
	func value():
		return _value
	
	func set_value(value) -> void:
		match _type:
			TYPE_STRING:
				_value = str(value)
			TYPE_BOOL:
				_value = bool(value)
			TYPE_INT:
				_value = int(value)
			TYPE_REAL:
				_value = float(value)
	
	func default():
		return _default
	
	func category() -> String:
		var elements := _name.split("/")
		if elements.size() > 3:
			return elements[2]
		return ""
	
	func help() -> String:
		return _help
	
	func _to_string() -> String:
		return "%-64s %-10s %-10s (%s) help:%s" % [name(), GdObjects.type_as_string(type()), value(), default(), help()]

static func setup():
	create_property_if_need(UPDATE_NOTIFICATION_ENABLED, true, "Enables/Disables the update notification on startup.")
	create_property_if_need(SERVER_TIMEOUT, DEFAULT_SERVER_TIMEOUT, "Sets the server connection timeout in minutes.")
	create_property_if_need(TEST_TIMEOUT, DEFAULT_TEST_TIMEOUT, "Sets the test case runtime timeout in seconds.")
	create_property_if_need(REPORT_ERROR_NOTIFICATIONS, false, "Current not supported!")
	create_property_if_need(REPORT_ORPHANS, true, "Enables/Disables orphan reporting.")
	create_property_if_need(REPORT_ASSERT_ERRORS, true, "Enables/Disables error reporting on asserts.")
	create_property_if_need(REPORT_ASSERT_WARNINGS, true, "Enables/Disables warning reporting on asserts")

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

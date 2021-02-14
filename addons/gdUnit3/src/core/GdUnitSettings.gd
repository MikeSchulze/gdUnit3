class_name GdUnitSettings
extends Reference

const CATEGORY = "gdunit"
const REPORT_ERROR_NOTIFICATIONS = CATEGORY + "/report/error_notification"
const REPORT_ERROR_INFO = CATEGORY + "/report/info"

static func load_settings():
	ProjectSettings.clear(REPORT_ERROR_NOTIFICATIONS)

	#if not ProjectSettings.has_setting(CATEGORY):
		
	var error_notification = {
		"name": REPORT_ERROR_NOTIFICATIONS,
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "Enable to report push error notifications"
	}
	ProjectSettings.set(REPORT_ERROR_NOTIFICATIONS, false)
	ProjectSettings.add_property_info(error_notification)
	ProjectSettings.set_initial_value(REPORT_ERROR_NOTIFICATIONS, false)
	

	var ret = ProjectSettings.save()
	if ret != OK:
		prints(GdUnitTools.error_as_string(ret))
		push_error(GdUnitTools.error_as_string(ret))

static func is_report_push_errors() -> bool:
	if ProjectSettings.has_setting(REPORT_ERROR_NOTIFICATIONS):
		return ProjectSettings.get_setting(REPORT_ERROR_NOTIFICATIONS)
	return false

tool
class_name GdUnitSettings
extends Reference

const CATEGORY = "gdunit3"
const REPORT_ERROR_NOTIFICATIONS = CATEGORY + "/report/error_notification"
const REPORT_ERROR_INFO = CATEGORY + "/report/info"

static func load_settings():
	var is_settings_changed := false
	
	if not ProjectSettings.has_setting(REPORT_ERROR_NOTIFICATIONS):
		prints("GdUnit3: Set inital settings", REPORT_ERROR_NOTIFICATIONS)
		var error_notification = {
			"name": REPORT_ERROR_NOTIFICATIONS,
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "Enable to report push error notifications"
		}
		ProjectSettings.set(REPORT_ERROR_NOTIFICATIONS, false)
		ProjectSettings.add_property_info(error_notification)
		ProjectSettings.set_initial_value(REPORT_ERROR_NOTIFICATIONS, false)
		ProjectSettings.set_setting(REPORT_ERROR_NOTIFICATIONS, false)
		is_settings_changed = true
	
	if is_settings_changed: 
		var ret = ProjectSettings.save()
		if ret != OK:
			push_error(GdUnitTools.error_as_string(ret))
			return
		else:
			prints("GdUnit3: Settings succesfully saved.")
	else:
		prints("GdUnit3: Settings successfully loaded.")

static func is_report_push_errors() -> bool:
	if ProjectSettings.has_setting(REPORT_ERROR_NOTIFICATIONS):
		return ProjectSettings.get_setting(REPORT_ERROR_NOTIFICATIONS)
	return false

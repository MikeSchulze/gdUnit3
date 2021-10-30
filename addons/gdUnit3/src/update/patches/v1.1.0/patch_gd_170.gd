extends GdUnitPatch

# common settings
const OLD_UPDATE_NOTIFICATION_ENABLED = GdUnitSettings.COMMON_SETTINGS + "/update_notification_enabled"
const OLD_SERVER_TIMEOUT = GdUnitSettings.COMMON_SETTINGS + "/server_connection_timeout_minutes"

# test settings
const OLD_TEST_TIMEOUT = GdUnitSettings.COMMON_SETTINGS + "/test_timeout_seconds"
const OLD_TEST_ROOT_FOLDER = GdUnitSettings.COMMON_SETTINGS + "/test_root_folder"

func _init() .(GdUnit3Version.parse("v1.1.0")):
	pass

func execute() -> bool:
	# migrate existing test properties to a group 'common'
	GdUnitSettings.migrate_property(OLD_UPDATE_NOTIFICATION_ENABLED, GdUnitSettings.UPDATE_NOTIFICATION_ENABLED)
	GdUnitSettings.migrate_property(OLD_SERVER_TIMEOUT, GdUnitSettings.SERVER_TIMEOUT)
	
	# migrate existing test properties to a group 'test'
	GdUnitSettings.migrate_property(OLD_TEST_TIMEOUT, GdUnitSettings.TEST_TIMEOUT)
	GdUnitSettings.migrate_property(OLD_TEST_ROOT_FOLDER, GdUnitSettings.TEST_ROOT_FOLDER)
	return true

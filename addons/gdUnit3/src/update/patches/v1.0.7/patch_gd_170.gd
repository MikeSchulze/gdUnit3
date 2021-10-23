extends GdUnitPatch

const OLD_TEST_TIMEOUT = GdUnitSettings.COMMON_SETTINGS + "/test_timeout_seconds"
const OLD_TEST_ROOT_FOLDER = GdUnitSettings.COMMON_SETTINGS + "/test_root_folder"

func _init() .(GdUnit3Version.parse("v1.0.7")):
	pass

func execute() -> bool:
	# migrate existing test properties to a group 'test'
	GdUnitSettings.migrate_property(OLD_TEST_TIMEOUT, GdUnitSettings.TEST_TIMEOUT)
	GdUnitSettings.migrate_property(OLD_TEST_ROOT_FOLDER, GdUnitSettings.TEST_ROOT_FOLDER)
	return true

# GdUnit generated TestSuite
class_name GdUnitPatcherTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/update/GdUnitPatcher.gd'

const _patches := "res://addons/gdUnit3/test/update/resources/patches/"

var _patcher :GdUnitPatcher

func before():
	_patcher = auto_free(GdUnitPatcher.new())

func before_test():
	Engine.set_meta(GdUnitPatch.PATCH_VERSION, [])
	_patcher._patches.clear()

func test__collect_patch_versions_no_patches() -> void:
	# using higher version than patches exists in patch folder
	assert_array(_patcher._collect_patch_versions(_patches, GdUnit3Version.new(3,0,0))).is_empty()

func test__collect_patch_versions_current_eq_latest_version() -> void:
	# using equal version than highst available patch
	assert_array(_patcher._collect_patch_versions(_patches, GdUnit3Version.new(1,1,4))).is_empty()

func test__collect_patch_versions_current_lower_latest_version() -> void:
	# using one version lower than highst available patch
	assert_array(_patcher._collect_patch_versions(_patches, GdUnit3Version.new(0,9,9)))\
		.contains_exactly(["res://addons/gdUnit3/test/update/resources/patches/v1.1.4"])
	
	# using two versions lower than highst available patch
	assert_array(_patcher._collect_patch_versions(_patches, GdUnit3Version.new(0,9,8)))\
		.contains_exactly([
			"res://addons/gdUnit3/test/update/resources/patches/v0.9.9",
			"res://addons/gdUnit3/test/update/resources/patches/v1.1.4"])
	
	# using three versions lower than highst available patch
	assert_array(_patcher._collect_patch_versions(_patches, GdUnit3Version.new(0,9,5)))\
		.contains_exactly([
			"res://addons/gdUnit3/test/update/resources/patches/v0.9.6",
			"res://addons/gdUnit3/test/update/resources/patches/v0.9.9",
			"res://addons/gdUnit3/test/update/resources/patches/v1.1.4"])

func test_scan_patches() -> void:
	_patcher._scan(_patches, GdUnit3Version.new(0,9,6))
	assert_dict(_patcher._patches)\
		.contains_key_value("res://addons/gdUnit3/test/update/resources/patches/v0.9.9", PoolStringArray(["patch_a.gd", "patch_b.gd"]))\
		.contains_key_value("res://addons/gdUnit3/test/update/resources/patches/v1.1.4", PoolStringArray(["patch_a.gd"]))
	assert_int(_patcher.patch_count()).is_equal(3)
	
	_patcher._patches.clear()
	_patcher._scan(_patches, GdUnit3Version.new(0,9,5))
	assert_dict(_patcher._patches)\
		.contains_key_value("res://addons/gdUnit3/test/update/resources/patches/v0.9.6", PoolStringArray(["patch_x.gd"]))\
		.contains_key_value("res://addons/gdUnit3/test/update/resources/patches/v0.9.9", PoolStringArray(["patch_a.gd", "patch_b.gd"]))\
		.contains_key_value("res://addons/gdUnit3/test/update/resources/patches/v1.1.4", PoolStringArray(["patch_a.gd"]))
	assert_int(_patcher.patch_count()).is_equal(4)
	
func test_execute_no_patches() -> void:
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()
	
	_patcher.execute()
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()

func test_execute_v_095() -> void:
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()
	_patcher._scan(_patches, GdUnit3Version.parse("v0.9.5"))
	
	_patcher.execute()
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_equal([
		GdUnit3Version.parse("v0.9.6"),
		GdUnit3Version.parse("v0.9.9-a"),
		GdUnit3Version.parse("v0.9.9-b"),
		GdUnit3Version.parse("v1.1.4"),
	])

func test_execute_v_096() -> void:
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()
	_patcher._scan(_patches, GdUnit3Version.parse("v0.9.6"))
	
	_patcher.execute()
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_equal([
		GdUnit3Version.parse("v0.9.9-a"),
		GdUnit3Version.parse("v0.9.9-b"),
		GdUnit3Version.parse("v1.1.4"),
	])

func test_execute_v_099() -> void:
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()
	_patcher._scan(_patches, GdUnit3Version.new(0,9,9))
	
	_patcher.execute()
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_equal([
		GdUnit3Version.parse("v1.1.4"),
	])

func test_execute_v_150() -> void:
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()
	_patcher._scan(_patches, GdUnit3Version.parse("v1.5.0"))
	
	_patcher.execute()
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()


func test_execute_update_v106_to_v107() -> void:
	# save project settings before modify by patching
	GdUnitSettings.dump_to_tmp()
	assert_array(Engine.get_meta(GdUnitPatch.PATCH_VERSION)).is_empty()
	_patcher.scan(GdUnit3Version.parse("v1.0.6"))
	
	# add v1.0.6 properties
	var old_test_timeout = "gdunit3/settings/test_timeout_seconds"
	var old_test_root_folder = "gdunit3/settings/test_root_folder"
	GdUnitSettings.create_property_if_need(old_test_timeout, GdUnitSettings.DEFAULT_TEST_TIMEOUT, "Sets the test case runtime timeout in seconds.")
	GdUnitSettings.create_property_if_need(old_test_root_folder, GdUnitSettings.DEFAULT_TEST_ROOT_FOLDER, "Sets the root folder where test-suites located/generated.")
	assert_bool(ProjectSettings.has_setting(old_test_timeout)).is_true()
	assert_bool(ProjectSettings.has_setting(old_test_root_folder)).is_true()
	
	# execute the patch
	_patcher.execute()
	
	# verify
	var new_test_timeout = "gdunit3/settings/test/test_timeout_seconds"
	var new_test_root_folder = "gdunit3/settings/test/test_root_folder"
	assert_bool(ProjectSettings.has_setting(old_test_timeout)).is_false()
	assert_bool(ProjectSettings.has_setting(old_test_root_folder)).is_false()
	assert_bool(ProjectSettings.has_setting(new_test_timeout)).is_true()
	assert_bool(ProjectSettings.has_setting(new_test_root_folder)).is_true()
	# restore orignal project settings
	GdUnitSettings.restore_dump_from_tmp()
	yield(get_tree(), "idle_frame")

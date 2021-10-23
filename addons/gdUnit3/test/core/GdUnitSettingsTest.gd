# GdUnit generated TestSuite
class_name GdUnitSettingsTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitSettings.gd'

const MAIN_CATEGORY = "unit_test"
const CATEGORY_A = MAIN_CATEGORY + "/category_a"
const CATEGORY_B = MAIN_CATEGORY + "/category_b"
const TEST_PROPERTY_A = CATEGORY_A + "/a/prop_a"
const TEST_PROPERTY_B = CATEGORY_A + "/a/prop_b"
const TEST_PROPERTY_C = CATEGORY_A + "/a/prop_c"
const TEST_PROPERTY_D = CATEGORY_B + "/prop_d"
const TEST_PROPERTY_E = CATEGORY_B + "/c/prop_e"
const TEST_PROPERTY_F = CATEGORY_B + "/c/prop_f"
const TEST_PROPERTY_G = CATEGORY_B + "/a/prop_g"

func before_test() -> void:
	GdUnitSettings.create_property_if_need(TEST_PROPERTY_A, true, "helptext TEST_PROPERTY_A.")
	GdUnitSettings.create_property_if_need(TEST_PROPERTY_B, false, "helptext TEST_PROPERTY_B.")
	GdUnitSettings.create_property_if_need(TEST_PROPERTY_C, 100, "helptext TEST_PROPERTY_C.")
	GdUnitSettings.create_property_if_need(TEST_PROPERTY_D, true, "helptext TEST_PROPERTY_D.")
	GdUnitSettings.create_property_if_need(TEST_PROPERTY_E, false, "helptext TEST_PROPERTY_E.")
	GdUnitSettings.create_property_if_need(TEST_PROPERTY_F, "abc", "helptext TEST_PROPERTY_F.")
	GdUnitSettings.create_property_if_need(TEST_PROPERTY_G, 200, "helptext TEST_PROPERTY_G.")

func after_test() -> void:
	ProjectSettings.clear(TEST_PROPERTY_A)
	ProjectSettings.clear(TEST_PROPERTY_B)
	ProjectSettings.clear(TEST_PROPERTY_C)
	ProjectSettings.clear(TEST_PROPERTY_D)
	ProjectSettings.clear(TEST_PROPERTY_E)
	ProjectSettings.clear(TEST_PROPERTY_F)
	ProjectSettings.clear(TEST_PROPERTY_G)

func test_list_settings() -> void:
	var settingsA := GdUnitSettings.list_settings(CATEGORY_A)
	assert_array(settingsA).extractv(extr("name"), extr("type"), extr("value"), extr("default"), extr("help"))\
		.contains_exactly_in_any_order([
		tuple(TEST_PROPERTY_A, TYPE_BOOL, true, true, "helptext TEST_PROPERTY_A."),
		tuple(TEST_PROPERTY_B, TYPE_BOOL,false, false, "helptext TEST_PROPERTY_B."),
		tuple(TEST_PROPERTY_C, TYPE_INT, 100, 100, "helptext TEST_PROPERTY_C.")
	])
	var settingsB := GdUnitSettings.list_settings(CATEGORY_B)
	assert_array(settingsB).extractv(extr("name"), extr("type"), extr("value"), extr("default"), extr("help"))\
		.contains_exactly_in_any_order([
		tuple(TEST_PROPERTY_D, TYPE_BOOL, true, true, "helptext TEST_PROPERTY_D."),
		tuple(TEST_PROPERTY_E, TYPE_BOOL, false, false, "helptext TEST_PROPERTY_E."),
		tuple(TEST_PROPERTY_F, TYPE_STRING, "abc", "abc", "helptext TEST_PROPERTY_F."),
		tuple(TEST_PROPERTY_G, TYPE_INT, 200, 200, "helptext TEST_PROPERTY_G.")
	])

func test_migrate_property_change_key() -> void:
	# setup old property
	var old_property_X = "/category_patch/group_old/name"
	var new_property_X = "/category_patch/group_new/name"
	GdUnitSettings.create_property_if_need(old_property_X, "foo")
	assert_str(GdUnitSettings.get_setting(old_property_X, null)).is_equal("foo")
	assert_str(GdUnitSettings.get_setting(new_property_X, null)).is_null()
	
	# migrate
	GdUnitSettings.migrate_property(old_property_X, new_property_X)
	
	assert_str(GdUnitSettings.get_setting(old_property_X, null)).is_null()
	assert_str(GdUnitSettings.get_setting(new_property_X, null)).is_equal("foo")

	# cleanup
	ProjectSettings.clear(new_property_X)

func convert_value(value :String) -> String:
	return "bar"

func test_migrate_property_change_value() -> void:
	# setup old property
	var old_property_X = "/category_patch/group_old/name"
	var new_property_X = "/category_patch/group_new/name"
	GdUnitSettings.create_property_if_need(old_property_X, "foo")
	assert_str(GdUnitSettings.get_setting(old_property_X, null)).is_equal("foo")
	assert_str(GdUnitSettings.get_setting(new_property_X, null)).is_null()
	
	# migrate property
	GdUnitSettings.migrate_property(old_property_X, new_property_X, funcref(self, "convert_value"))
	
	assert_str(GdUnitSettings.get_setting(old_property_X, null)).is_null()
	assert_str(GdUnitSettings.get_setting(new_property_X, null)).is_equal("bar")

	# cleanup
	ProjectSettings.clear(new_property_X)

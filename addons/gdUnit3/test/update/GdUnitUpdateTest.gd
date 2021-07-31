# GdUnit generated TestSuite
class_name GdUnitUpdateTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/update/GdUnitUpdate.gd'

func after_test():
	clean_temp_dir()

func test_extract_package() -> void:
	var tmp_path := GdUnitTools.create_temp_dir("test_update")
	var source := ProjectSettings.globalize_path("res://addons/gdUnit3/test/update/resources/update.zip")
	var dest := ProjectSettings.globalize_path(tmp_path)
	
	# the temp should be inital empty
	assert_array(GdUnitTools.scan_dir(dest)).is_empty()
	# now extract to temp
	var result := GdUnitUpdate._extract_package(source, dest)
	assert_result(result).is_success()
	assert_array(GdUnitTools.scan_dir(dest)).contains_exactly(["MikeSchulze-gdUnit3-910d61e"])
	assert_array(GdUnitTools.scan_dir(dest + "/MikeSchulze-gdUnit3-910d61e")).contains_exactly_in_any_order([
		"addons",
		"runtest.cmd",
		"runtest.sh",
	])

func test_extract_package_invalid_package() -> void:
	var tmp_path := GdUnitTools.create_temp_dir("test_update")
	var source := ProjectSettings.globalize_path("res://addons/gdUnit3/test/update/resources/update_invalid.zip")
	var dest := ProjectSettings.globalize_path(tmp_path)
	
	# the temp should be inital empty
	assert_array(GdUnitTools.scan_dir(dest)).is_empty()
	# now extract to temp
	var result := GdUnitUpdate._extract_package(source, dest)
	assert_result(result).is_error()\
		.contains_message("Extracting `%s` failed! Please collect the error log and report this." % source)
	assert_array(GdUnitTools.scan_dir(dest)).is_empty()

func test__prepare_update_deletes_old_content() -> void:
	var update :GdUnitUpdate = auto_free(GdUnitUpdate.new())
	update._info_progress = mock(ProgressBar)
	update._info_popup = mock(Popup)
	update._info_content = mock(Label)
	
	# precheck the update temp is empty
	clean_temp_dir()
	assert_array(GdUnitTools.scan_dir("user://tmp/update")).is_empty()
	
	# on empty tmp update directory
	assert_dict(update._prepare_update())\
		.contains_key_value("tmp_path", "user://tmp/update")\
		.contains_key_value("zip_file", "user://tmp/update/update.zip")
	
	# put some artifacts on tmp update directory
	create_temp_dir("update/data1")
	create_temp_dir("update/data2")
	create_temp_file("update", "update.zip").close()
	assert_array(GdUnitTools.scan_dir("user://tmp/update")).contains_exactly_in_any_order([
		"data1",
		"data2",
		"update.zip",
	])
	# call prepare update at twice where should cleanup old artifacts
	update._prepare_update()
	assert_array(GdUnitTools.scan_dir("user://tmp/update")).is_empty()

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

# GdUnit generated TestSuite
class_name GdUnitToolsTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitTools.gd'
var file_to_save :String

# setup test data
func before():
	# opens a tmp file with WRITE mode under "user://tmp/examples/game/game.sav" (auto closed)
	var file := create_temp_file("examples/game", "game.sav")
	assert_object(file).is_not_null()
	# write some example data
	file.store_line("some data")
	# not needs to be manually close, will be auto closed before test execution

func after():
	assert_bool(File.new().file_exists(file_to_save)).is_false()

func test_create_temp_dir():
	var temp_dir := create_temp_dir("examples/game/save")
	file_to_save = temp_dir + "/save_game.dat"
	
	var data = {
		'user': "Hoschi",
		'level': 42
	}
	var file := File.new()
	file.open(file_to_save, File.WRITE)
	file.store_line(JSON.print(data))
	file.close()
	assert_bool(File.new().file_exists(file_to_save)).is_true()

func test_error_as_string():
	assert_str(error_as_string(ERR_CONNECTION_ERROR)).is_equal("Connection error.")
	assert_str(error_as_string(1000)).is_equal("Unknown error number 1000")


func test_create_temp_file():
	# opens the stored tmp file with READ mode under "user://tmp/examples/game/game.sav" (auto closed)
	var file_read := create_temp_file("examples/game", "game.sav", File.READ)
	assert_object(file_read).is_not_null()
	assert_str(file_read.get_as_text()).is_equal("some data\n")
	# not needs to be manually close, will be auto closed after test suite execution

func test_copy_directory():
	var temp_dir := create_temp_dir("test_copy_directory")
	assert_bool(GdUnitTools.copy_directory("res://addons/gdUnit3/test/core/resources/copy_test/folder_a/", temp_dir)).is_true()
	assert_file("%s/folder_a/file_a.txt" % temp_dir).exists()
	assert_file("%s/folder_a/file_b.txt" % temp_dir).exists()
	# TODO extends test with verify directory content assert_dir()
	
func test_copy_directory_recursive():
	var temp_dir := create_temp_dir("test_copy_directory_recursive")
	assert_bool(GdUnitTools.copy_directory("res://addons/gdUnit3/test/core/resources/copy_test/", temp_dir, true)).is_true()
	assert_file("%s/copy_test/folder_a/file_a.txt" % temp_dir).exists()
	assert_file("%s/copy_test/folder_a/file_b.txt" % temp_dir).exists()
	assert_file("%s/copy_test/folder_b/file_a.txt" % temp_dir).exists()
	assert_file("%s/copy_test/folder_b/file_b.txt" % temp_dir).exists()
	assert_file("%s/copy_test/folder_b/folder_ba/file_x.txt" % temp_dir).exists()
	assert_file("%s/copy_test/folder_c/file_z.txt" % temp_dir).exists()
	# TODO extends test with verify directory content assert_dir()

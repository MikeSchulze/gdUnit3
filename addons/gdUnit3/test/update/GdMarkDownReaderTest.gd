# GdUnit generated TestSuite
class_name GdMarkDownReaderTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/update/GdMarkDownReader.gd'

var _reader :GdMarkDownReader
var _client :GdUnitUpdateClient

func before():
	_client = GdUnitUpdateClient.new()
	add_child(_client)
	_reader = GdMarkDownReader.new()
	_reader.set_http_client(_client)
	add_child(_reader)

func after():
	_client.queue_free()
	_reader.free()

func test_tobbcode() -> void:
	var source := resource_as_string("res://addons/gdUnit3/test/update/resources/markdown_example.txt")
	var expected := resource_as_string("res://addons/gdUnit3/test/update/resources/bbcode_example.txt")
	assert_str(yield(_reader.to_bbcode(source), "completed")).is_equal(expected)

func test_tobbcode_table() -> void:
	var source := resource_as_string("res://addons/gdUnit3/test/update/resources/markdown_table.txt")
	var expected := resource_as_string("res://addons/gdUnit3/test/update/resources/bbcode_table.txt")
	assert_str(yield(_reader.to_bbcode(source), "completed")).is_equal(expected)

func test_tobbcode_list() -> void:
	assert_str(yield(_reader.to_bbcode("- item"), "completed")).is_equal("[img=12x12]res://addons/gdUnit3/src/update/assets/dot1.png[/img] item")
	assert_str(yield(_reader.to_bbcode("  - item"), "completed")).is_equal("   [img=12x12]res://addons/gdUnit3/src/update/assets/dot2.png[/img] item")
	assert_str(yield(_reader.to_bbcode("    - item"), "completed")).is_equal("      [img=12x12]res://addons/gdUnit3/src/update/assets/dot1.png[/img] item")
	assert_str(yield(_reader.to_bbcode("      - item"), "completed")).is_equal("         [img=12x12]res://addons/gdUnit3/src/update/assets/dot2.png[/img] item")


func test_to_bbcode_embeded_text() -> void:
	assert_str(yield(_reader.to_bbcode("> some text"), "completed")).is_equal("[img=50x14]res://addons/gdUnit3/src/update/assets/embedded.png[/img][i] some text[/i]")

func test_process_image() -> void:
	#regex("!\\[(.*?)\\]\\((.*?)(( )+(.*?))?\\)")
	var reg_ex :RegEx = _reader.md_replace_patterns[11][0]
	
	# without tooltip
	assert_str(_reader.process_image(reg_ex, "![alt text](res://addons/gdUnit3/test/update/resources/icon48.png)"))\
		.is_equal("[img]res://addons/gdUnit3/test/update/resources/icon48.png[/img]")
	# with tooltip
	assert_str(_reader.process_image(reg_ex, "![alt text](res://addons/gdUnit3/test/update/resources/icon48.png \"Logo Title Text 1\")"))\
		.is_equal("[img]res://addons/gdUnit3/test/update/resources/icon48.png[/img]")
	# multiy lines
	var input := """
![alt text](res://addons/gdUnit3/test/update/resources/icon48.png)

![alt text](res://addons/gdUnit3/test/update/resources/icon23.png \"Logo Title Text 1\")

"""
	var expected := """
[img]res://addons/gdUnit3/test/update/resources/icon48.png[/img]

[img]res://addons/gdUnit3/test/update/resources/icon23.png[/img]

"""
	assert_str(_reader.process_image(reg_ex, input))\
		.is_equal(expected)

func test_process_image_by_reference() -> void:
	#regex("!\\[(.*?)\\]\\((.*?)(( )+(.*?))?\\)")
	var reg_ex :RegEx = _reader.md_replace_patterns[10][0]
	var input := """
![alt text1][logo-1]

[logo-1]:https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 2"

![alt text2][logo-1]

"""

	var expected := """
![alt text1](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png)


![alt text2](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png)

"""
	
	# without tooltip
	assert_str(_reader.process_image_references(reg_ex, input))\
		.is_equal(expected)

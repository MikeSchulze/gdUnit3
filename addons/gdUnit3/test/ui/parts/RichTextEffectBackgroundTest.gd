# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name RichTextEffectBackgroundTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/ui/parts/RichTextEffectBackground.gd'


func assert_mapping(mapping :Dictionary, message :String, effect :RichTextEffectBackground):
	var char_width := effect._char_size.x
	var char_height := effect.get_line_height()
	
	var char_pos := 0
	var y := 0
	for line in message.split("\n"):
		for x in line.length():
			x += effect.get_line_indent(y)
			var expected_pos := Vector2(x*char_width, y*char_height)
			assert_vector2(mapping.get(char_pos))\
				.is_equal(expected_pos)
			char_pos += 1
		y += 1

func test_build_char_mapping_singe_line() -> void:
	var rtl = auto_free(RichTextLabelExt.new())
	var effect := RichTextEffectBackground.new(rtl)
	rtl.install_effect(effect)
	
	var message := "This is a Message"
	var mapping := effect._build_char_mapping(message)
	
	assert_mapping(mapping, message, effect)

func test_build_char_mapping_multi_line() -> void:
	var rtl = auto_free(RichTextLabelExt.new())
	var effect := RichTextEffectBackground.new(rtl)
	rtl.install_effect(effect)
	
	var message := "This is a Message\nAnd an another Message\nEOF"
	var mapping := effect._build_char_mapping(message)
	
	assert_mapping(mapping, message, effect)

func test_get_line_indent() -> void:
	var rtl = auto_free(RichTextLabelExt.new())
	var effect := RichTextEffectBackground.new(rtl)
	rtl._effect = effect
	
	assert_int(effect.get_line_indent(1)).is_equal(0)
	assert_int(effect.get_line_indent(2)).is_equal(0)
	
	# indent = 0
	rtl.append_bbcode("This is line 1")
	rtl.newline()

	# indent = 2
	rtl.push_indent(2)
	rtl.append_bbcode("This is line 2")
	rtl.newline()
	rtl.pop_indent(2)
	
	# indent = 0
	rtl.append_bbcode("This is line 3")
	rtl.newline()
	
	# indent = 2
	rtl.push_indent(2)
	rtl.append_bbcode("This is line 4")
	rtl.newline()
	
	# indent = 4
	rtl.push_indent(2)
	rtl.append_bbcode("This is line 5")
	rtl.newline()
	rtl.pop_indent(2)
	rtl.pop_indent(2)
	# indent = 0
	
	assert_int(effect.get_line_indent(1)).is_equal(0)
	assert_int(effect.get_line_indent(2)).is_equal(2)
	assert_int(effect.get_line_indent(3)).is_equal(0)
	assert_int(effect.get_line_indent(4)).is_equal(2)
	assert_int(effect.get_line_indent(5)).is_equal(4)

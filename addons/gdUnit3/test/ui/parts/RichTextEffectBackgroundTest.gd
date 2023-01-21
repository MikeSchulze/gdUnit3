# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name RichTextEffectBackgroundTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/ui/parts/RichTextEffectBackground.gd'


func test_paint_with_diff() -> void:
	var label = spy(auto_free(RichTextLabelExt.new()))
	add_child(label)
	var diff_color := Color.red
	var message := "This is [bg color="  + diff_color.to_html() +"]X[/bg] Message"
	label.set_bbcode(message)
	
	# draw it
	yield(get_tree(), "idle_frame")
	
	# the background color is using .3 for alpha value
	diff_color.a = .3
	verify(label, 1).draw_rect(Rect2(68, 4 ,8, 16), diff_color)


func test_paint_no_diff() -> void:
	var label = spy(auto_free(RichTextLabelExt.new()))
	add_child(label)
	var message := "This is a Message"
	label.set_bbcode(message)
	
	# draw it
	yield(get_tree(), "idle_frame")
	
	# no diff rect should be drawn
	verify(label, 0).draw_rect(any(), any())

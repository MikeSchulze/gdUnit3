# Custom RichTextLabel with custom background colors
# MIT License
# Copyright (c) 2020 Mike Schulze
# https://github.com/MikeSchulze/gdUnit3/blob/master/LICENSE

tool
extends RichTextLabel
class_name RichTextLabelExt

var _effect :RichTextEffectBackground
var _indent :int

func setup_effects() -> void:
	_effect = RichTextEffectBackground.new(self)
	install_effect(_effect)

func set_bbcode(code) -> void:
	_effect.reset()
	.parse_bbcode(code)
	updateMinSize()

func append_bbcode(text :String):
	# replace all tabs, it results in invalid background coloring
	return .append_bbcode(text.replace("\t", ""))

func clone() -> RichTextLabelExt:
	var clone = .duplicate()
	clone.setup_effects()
	return clone

func push_indent(indent :int) -> void:
	.push_indent(indent)
	if _effect:
		_indent += indent
		_effect.push_indent(get_line_count(), _indent)

func pop_indent(indent :int) -> void:
	.pop()
	if _effect:
		_indent -= indent
		_effect.pop_indent(get_line_count(), _indent)

# updates the label minmum size by the longest line content
# to fit the full test to on line, to avoid line wrapping
func updateMinSize() -> void:
	var min_size := Vector2(0, 0)
	var lines := get_text().split("\n")
	for line in lines:
		var chars = line.length() + 1
		if min_size.x < chars:
			min_size.x = chars
	min_size.x *= _effect.get_char_size().x
	set("rect_min_size", min_size)

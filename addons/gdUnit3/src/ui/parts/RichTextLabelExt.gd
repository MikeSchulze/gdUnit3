# Custom RichTextLabel with custom background colors
# MIT License
# Copyright (c) 2020 Mike Schulze
# https://github.com/MikeSchulze/gdUnit3/blob/master/LICENSE

tool
extends RichTextLabel
class_name RichTextLabelExt

var _effect :RichTextEffectBackground = RichTextEffectBackground.new()
var _indent :int


func _ready():
	_update_ui_settings()
	_effect.set_source(self)
	# clear effects otherwies a duplicate will result in errors
	set_effects([])
	install_effect(_effect)

func _notification(what):
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		_update_ui_settings()
		if _effect:
			_effect._notification(what)

func _update_ui_settings():
	Fonts.init_fonts(self)
	updateMinSize()

func set_bbcode(code) -> void:
	.parse_bbcode(code)
	updateMinSize()

func append_bbcode(text :String):
	# replace all tabs, it results in invalid background coloring
	var error := .append_bbcode(text.replace("\t", ""))
	updateMinSize()
	return error

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
# to fit the full text to on line, to avoid line wrapping
func updateMinSize() -> void:
	# reset curren min size
	rect_min_size.x = 0
	var font := get("custom_fonts/font") as Font
	var lines := get_text().split("\n")
	for line in lines:
		var line_size := font.get_string_size(line)
		if rect_min_size < line_size:
			rect_min_size = line_size
	# add extra space of 80, the calculated 'get_string_size' not fits right the line wrap size
	rect_min_size.x += 80

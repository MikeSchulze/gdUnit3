# Custom RichTextLabel with custom background colors
# MIT License
# Copyright (c) 2020 Mike Schulze
# https://github.com/MikeSchulze/gdUnit3/blob/master/LICENSE

tool
extends RichTextLabel
class_name RichTextLabelExt

var _effect :RichTextEffectBackground = RichTextEffectBackground.new()
var _indent :int
var _max_indent : int = 0

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
	GdUnitFonts.init_fonts(self)
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
	if _indent > _max_indent:
		_max_indent = _indent

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
	# calculate additional indent characters
	var indent_chars = _max_indent * get_tab_size()
	var extra_chars = ("%+" + str(indent_chars) + "s") % " "
	
	for line in lines:
		var line_size := font.get_string_size(line + extra_chars)
		if rect_min_size < line_size:
			rect_min_size = line_size
	# add extra spacing of 40px for possible scrollbar
	rect_min_size.x += 40

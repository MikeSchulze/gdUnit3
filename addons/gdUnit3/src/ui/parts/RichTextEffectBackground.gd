# This effect works currently only with mono fonts

# MIT License
# Copyright (c) 2020 Mike Schulze
# https://github.com/MikeSchulze/gdUnit3/blob/master/LICENSE

extends RichTextEffect
class_name RichTextEffectBackground

var bbcode = "bg"

var _label: WeakRef
var _char_size :Vector2
var _char_width := 8
var _char_height := 16
var _tab_size : int
var _indent := Dictionary()
var diff_sub_color := Color(0, 0, 0, 0)
var _cache := Dictionary() 

func _init(label :RichTextLabel):
	_label = weakref(label)
	# determine character size
	var custom_font = label.get("custom_fonts/normal_font")
	if custom_font is Font:
		_char_height = custom_font.get_height()
		_char_width = custom_font.get_char_size(23).x
	_char_size = Vector2(_char_width, _char_height)
	_tab_size = label.tab_size

func push_indent(line :int, indent :int) -> void:
	_indent[line] = indent

func pop_indent(line :int, indent :int) -> void:
	_indent[line+1] = -indent
	_cache.clear()

func reset() -> void:
	_cache.clear()
	_indent.clear()

func get_text_rect(control :Control) -> Rect2:
	var style : StyleBox = control.get_stylebox("normal")
	return Rect2(style.get_offset(), control.get_size() - style.get_minimum_size())

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var label = _label.get_ref() as RichTextLabel
	var scroll = label.get_v_scroll()
	var position := get_char_position(char_fx.absolute_index, label.get_text())
	
	# padding
	position += Vector2(4, 4)
	# sync with scroll positon
	position.y -= scroll.value
	var color = char_fx.env.get("color", diff_sub_color) as Color
	# lower the alpha for better backround
	color.a = .3
	label.draw_rect(Rect2(position, _char_size), color)
	
	# increase the color lightning of the character (for better visualisation on background)
	char_fx.color = char_fx.color.lightened(.8)
	return true

func _build_char_mapping(text :String) -> Dictionary:
	_cache.clear()
	var line_height := get_line_height()
	var line_index := 0
	var char_offset := 0
	var y_offset := 0
	var last_ident := 0
	
	# replace all tabs, otherwise it will results in invalid background coloring
	for line in text.replace("\t", "").split("\n"):
		line_index += 1
		# build line x_offset by current line indent
		last_ident = get_line_indent(line_index, last_ident)
		var x_offset = last_ident * _tab_size
		
		for x in line.length():
			var char_index = char_offset + x
			_cache[char_index] = Vector2((x_offset + x)*_char_size.x, y_offset)
		# calculate next line offsets
		y_offset += line_height
		char_offset += line.length()
	return _cache

func get_char_position(char_index :int, text :String ) -> Vector2:
	if _cache.empty():
		_build_char_mapping(text)
	return _cache.get(char_index, Vector2.ONE)

func get_line_indent(line :int, last_indent := 0) -> int:
	var line_indent = _indent.get(line, 0)
	if line_indent == 0:
		return last_indent
	if line_indent < 0:
		return last_indent + line_indent
	return line_indent

func get_line_height() -> int:
	var label = _label.get_ref() as RichTextLabel
	var line_separation = label.get("custom_constants/line_separation")
	if not line_separation:
		line_separation = 1
	return get_char_size().y + line_separation

func get_char_size() -> Vector2:
	return _char_size

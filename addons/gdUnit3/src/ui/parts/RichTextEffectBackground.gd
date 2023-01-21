# This effect works currently only with mono fonts

# MIT License
# Copyright (c) 2023 Mike Schulze
# https://github.com/MikeSchulze/gdUnit3/blob/master/LICENSE

extends RichTextEffect
class_name RichTextEffectBackground

var bbcode = "bg"

var _label: WeakRef
var _char_size := Vector2(8, 16)
var _margin := Vector2.ZERO
var _tab_size :int
var _diff_sub_color := Color(0, 0, 0, 0)
var _cache := Dictionary() 

class CharacterInfo:
	var _position :Vector2
	var _size :Vector2
	
	func _init(position :Vector2, size :Vector2):
		_position = position
		_size = size


func set_source(label :RichTextLabel) -> void:
	_label = weakref(label)
	init_properties()


func init_properties() :
	_cache.clear()
	# determine character size
	var custom_font = _label.get_ref().get("custom_fonts/mono_font")
	if custom_font is Font:
		_char_size = Vector2(custom_font.get_char_size(23).x, custom_font.get_height())
	_tab_size = _label.get_ref().tab_size
	_margin = Vector2(4, 4)


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var label = _label.get_ref() as RichTextLabel
	var scroll = label.get_v_scroll()
	var char_info :CharacterInfo = get_char_position(char_fx, label.get_text())
	var position := char_info._position
	# margin
	position += _margin
	# sync with scroll positon
	position.y -= scroll.value
	var color = char_fx.env.get("color", _diff_sub_color) as Color
	# lower the alpha for better backround
	color.a = .3
	label.draw_rect(Rect2(position, char_info._size), color)
	# increase the color lightning of the character (for better visualisation on background)
	char_fx.color = char_fx.color.lightened(.8)
	return true


func _build_char_mapping(text :String) -> Dictionary:
	_cache.clear()
	var line_height := get_line_height()
	var line_index := 0
	var char_index := 0
	
	for line in text.split("\n"):
		var position = Vector2(0, line_height * line_index)
		for cp in line.length():
			var char_size := char_size(line, cp)
			_cache[char_index] = CharacterInfo.new(position, char_size)
			#prints( "line:%d:%d" % [line_index, char_index], "'%s' (%d)" % [text[char_index], text.ord_at(char_index)], position, "ident", last_ident)#, "tab:", text[text_index] == "\t", char_size)
			char_index += 1
			position.x += char_size.x
		line_index += 1
	return _cache


func char_size(line :String, index :int) -> Vector2:
	var character := line.ord_at(index)
	match character:
		9: return Vector2(_tab_size * _char_size.x, _char_size.y)
		_: return _char_size
	return _char_size


func get_char_position(char_fx: CharFXTransform, text :String ) -> CharacterInfo:
	if _cache.empty():
		_build_char_mapping(text)
	return _cache.get(char_fx.absolute_index, CharacterInfo.new(Vector2.ZERO, _char_size))


func get_line_height() -> int:
	var label = _label.get_ref() as RichTextLabel
	var line_separation = label.get("custom_constants/line_separation")
	if not line_separation:
		line_separation = 1
	return _char_size.y + line_separation


func get_text_rect(control :Control) -> Rect2:
	var style : StyleBox = control.get_stylebox("normal")
	return Rect2(style.get_offset(), control.get_size() - style.get_minimum_size())


func reset() -> void:
	_cache.clear()


func _notification(what):
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		init_properties()

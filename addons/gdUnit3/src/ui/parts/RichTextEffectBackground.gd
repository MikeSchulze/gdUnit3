# Custom background color effect (c)2021 Mike Schulze
# This effect works currently only for mono fonts
tool
extends RichTextEffect
class_name RichTextEffectBackground

var bbcode = "bg"

var _label: WeakRef
var _char_size :Vector2
var _char_width : = 8
var _char_height : = 16
var diff_sub_color := Color(0, 0, 0, 0)
var _cache := Dictionary() 

func _init(label :RichTextLabel):
	_label = weakref(label)
	var custom_font = label.get("custom_fonts/normal_font")
	if custom_font is Font:
		_char_height = custom_font.get_height()
		_char_width = custom_font.get_char_size(23).x
	_char_size = Vector2(_char_width, _char_height)
	var line_separation = label.get("custom_constants/line_separation")
	if line_separation:
		_char_height += line_separation
	else:
		# default line separation
		_char_height +=1

func reset() -> void:
	_cache.clear()

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var label = _label.get_ref() as RichTextLabel
	var scroll = label.get_v_scroll()
	var position := get_char_position(char_fx.absolute_index, label.text)
	# padding
	position += Vector2(4, 4)
	# sync with scroll positon
	position.y -= scroll.value
	var color = char_fx.env.get("color", diff_sub_color) as Color
	# set alpha to lower value for better backround
	color.a = .3
	label.draw_rect(Rect2(position, _char_size), color);
	char_fx.color = char_fx.color.lightened(.8)
	return true

func get_char_position(char_index :int, text :String ) -> Vector2:
	var position = _cache.get(char_index)
	if position is Vector2:
		return position as Vector2
	
	var x_offset := char_index
	var y_offset := 0
	for l in text.split("\n"):
		if x_offset < l.length():
			break
		y_offset += 1
		x_offset -= l.length()
	
	position = Vector2(x_offset*_char_width, y_offset*_char_height)
	_cache[char_index] = position
	return position

func get_char_size() -> Vector2:
	return _char_size

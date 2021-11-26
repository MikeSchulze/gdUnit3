tool
extends RichTextLabel
class_name RichTextLabelExt

var _effect :RichTextEffectBackground

func setup_effects() -> void:
	_effect = RichTextEffectBackground.new(self)
	install_effect(_effect)

func set_bbcode(code) -> void:
	_effect.reset()
	.parse_bbcode(code)
	updateMinSize()

func clone() -> RichTextLabelExt:
	var clone = .duplicate()
	clone.setup_effects()
	return clone

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

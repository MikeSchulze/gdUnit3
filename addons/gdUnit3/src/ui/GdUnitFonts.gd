class_name GdUnitFonts
extends Reference

const FONT_MONO             = "res://addons/gdUnit3/src/update/assets/fonts/static/RobotoMono-Regular.ttf"
const FONT_MONO_BOLT        = "res://addons/gdUnit3/src/update/assets/fonts/static/RobotoMono-Bold.ttf"
const FONT_MONO_BOLT_ITALIC = "res://addons/gdUnit3/src/update/assets/fonts/static/RobotoMono-BoldItalic.ttf"
const FONT_MONO_ITALIC      = "res://addons/gdUnit3/src/update/assets/fonts/static/RobotoMono-Italic.ttf"


static func init_fonts(item: CanvasItem) -> float:
	# add a defauld fallback font
	item.set("custom_fonts/font", create_font(FONT_MONO, 16))
	if Engine.editor_hint:
		var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
		var settings := plugin.get_editor_interface().get_editor_settings()
		var scale_factor :=  plugin.get_editor_interface().get_editor_scale()
		var font_size = settings.get_setting("interface/editor/main_font_size")
		font_size *= scale_factor
		var font_mono := create_font(FONT_MONO, font_size)
		item.set("custom_fonts/font", font_mono)
		item.set("custom_fonts/mono_font", font_mono)
		item.set("custom_fonts/normal_font", font_mono)
		item.set("custom_fonts/bold_font", create_font(FONT_MONO_BOLT, font_size))
		item.set("custom_fonts/bold_italics_font", create_font(FONT_MONO_BOLT_ITALIC, font_size))
		item.set("custom_fonts/italics_font", create_font(FONT_MONO_ITALIC, font_size))
		return font_size
	return 16.0

static func create_font(font_resource: String, size: float) -> Font:
	var font = DynamicFont.new()
	font.font_data = load(font_resource)
	font.size = size
	return font

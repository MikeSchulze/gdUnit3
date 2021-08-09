class_name GdUnit3Version
extends Reference

const VERSION_PATTERN = "[center][color=#9887c4]gd[/color][color=#7a57d6]Unit[/color][color=#9887c4]3[/color] [color=#9887c4]${version}[/color][/center]"

var _major :int
var _minor :int
var _patch :int

func _init(major :int, minor :int, patch :int):
	_major = major
	_minor = minor
	_patch = patch

static func parse(value :String) -> GdUnit3Version:
	var regex := RegEx.new()
	regex.compile("[a-zA-Z:,-]+")
	var cleaned := regex.sub(value, "", true)
	var parts := cleaned.split(".")
	var major := int(parts[0])
	var minor := int(parts[1])
	var patch := int(parts[2]) if parts.size() > 2 else 0
	return load("res://addons/gdUnit3/src/core/GdUnit3Version.gd").new(major, minor, patch)

static func current() -> GdUnit3Version:
	var config = ConfigFile.new()
	config.load('addons/gdUnit3/plugin.cfg')
	return parse(config.get_value('plugin', 'version'))

func equals(other :GdUnit3Version) -> bool:
	return _major == other._major and _minor == other._minor and _patch == other._patch

func is_greater(other :GdUnit3Version) -> bool:
	if _major > other._major:
		return true
	if _major == other._major and _minor > other._minor:
		return true
	return _major == other._major and _minor == other._minor and _patch > other._patch

static func init_version_label(label :RichTextLabel) -> void:
	var config = ConfigFile.new()
	config.load('addons/gdUnit3/plugin.cfg')
	var version = config.get_value('plugin', 'version')
	label.bbcode_text = VERSION_PATTERN.replace('${version}', version)

func _to_string() -> String:
	return "v%d.%d.%d" % [_major, _minor, _patch]

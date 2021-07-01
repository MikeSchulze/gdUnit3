tool
extends HBoxContainer

signal run_pressed
signal stop_pressed

onready var _label := $description/version
onready var _button_wiki := $description/wiki

onready var _button_run := $Tools/run
onready var _button_run_debug := $Tools/debug
onready var _button_stop := $Tools/stop

func _ready():
	var editor :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	var editiorTheme := editor.get_editor_interface().get_base_control().theme
	_button_run.icon = editiorTheme.get_icon("Play", "EditorIcons")
	_button_stop.icon = editiorTheme.get_icon("Stop", "EditorIcons")

	var config = ConfigFile.new()
	config.load('addons/gdUnit3/plugin.cfg')
	var version = config.get_value('plugin', 'version')
	_label.bbcode_text = _label.bbcode_text.replace('${version}', version)

func _on_run_pressed(debug :bool=false):
	emit_signal("run_pressed", debug)

func _on_stop_pressed():
	emit_signal("stop_pressed")

func _on_GdUnit_gdunit_runner_start():
	_button_run.disabled = true
	_button_run_debug.disabled = true
	_button_stop.disabled = false

func _on_GdUnit_gdunit_runner_stop(client_id :int):
	_button_run.disabled = false
	_button_run_debug.disabled = false
	_button_stop.disabled = true

func _on_wiki_pressed():
	OS.shell_open("https://github.com/MikeSchulze/gdUnit3/wiki")

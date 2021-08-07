tool
extends HBoxContainer

signal run_pressed
signal stop_pressed

onready var _version_label := $description/CenterContainer/version
onready var _button_wiki := $Tools/help
onready var _tool_button := $Tools/tool

onready var _button_run := $Tools/run
onready var _button_run_debug := $Tools/debug
onready var _button_stop := $Tools/stop
onready var _tool_popup :WindowDialog = $GdUnitToolsDialog

func _ready():
	GdUnit3Version.init_version_label(_version_label)
	var editor :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	var editiorTheme := editor.get_editor_interface().get_base_control().theme
	_button_run.icon = editiorTheme.get_icon("Play", "EditorIcons")
	_button_stop.icon = editiorTheme.get_icon("Stop", "EditorIcons")
	_tool_button.icon = editiorTheme.get_icon("Tools", "EditorIcons")
	_button_wiki.icon = editiorTheme.get_icon("HelpSearch", "EditorIcons")


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


func _on_btn_tool_pressed():
	_tool_popup.popup_centered()


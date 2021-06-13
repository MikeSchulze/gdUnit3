extends Control

onready var _label = $Label
onready var _state_label = $game_state/label
onready var _state_bar = $game_state
onready var _ui := $GUI
onready var _main_scene = $MainScene

# holds singleton game repository instance
var _game_repository := GameRepository.instance()

func _ready():
	OS.window_maximized = true
	_label.text = "App started"
	_state_label.text = "Game Init"
	_state_bar.color = Color.darkgoldenrod
	_game_repository.connect("new_game", self, "_on_new_game")
	_game_repository.connect("load_game", self, "_on_load_game")
	_game_repository.connect("save_game", self, "_on_save_game")
	_ui.connect("game_paused", self, "_on_game_paused")
	
func _unhandled_input(event :InputEvent):
	var _debug = false
	if _debug and event is InputEventKey:
		prints("---------------------")
		prints(event, event.as_text())
		var key_event :InputEventKey = event
		prints("code", key_event.scancode)
		prints("command", key_event.command)
		prints("echo", key_event.echo)
		prints("pressed", key_event.pressed)
		prints("---------------------")
	
	if event.is_action_released("ui_cancel"):
		_ui.open_menu()
		_main_scene.pause_mode = true
		accept_event()

func _on_new_game():
	_label.text = "Starting a new Game"

func _on_load_game(name :String):
	_label.text = "Loading Game: %s" % name

func _on_save_game(name :String):
	_label.text = "Game: %s saved" % name

func _on_game_paused(paused :bool) -> void:
	if paused:
		_state_bar.color = Color.darkred
		_state_label.text = "Game Paused"
	else:
		_state_bar.color = Color.darkgreen
		_state_label.text = "Game Running"

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# needs to be manual freeing the singleton
		_game_repository._notification(what)

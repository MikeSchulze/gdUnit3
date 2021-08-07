extends MenuDialog

signal game_exit

export var save_game_availabe : bool = false

onready var _button_load_game :TextureButton = $VBoxContainer/LoadGame
onready var _button_load_game_label :Label = $VBoxContainer/LoadGame/Label

onready var _new_game = preload("res://gdUnit3-examples/MenuDemo2D/src/menu/NewGame.tscn")
onready var _load_game = preload("res://gdUnit3-examples/MenuDemo2D/src/menu/LoadGame.tscn")
onready var _save_game = preload("res://gdUnit3-examples/MenuDemo2D/src/menu/SaveGame.tscn")
onready var _options = preload("res://gdUnit3-examples/MenuDemo2D/src/menu/Options.tscn")

# inital focus to load game
onready var _last_focus :Control = $VBoxContainer/LoadGame

func _ready():
	# add listener to set/restore the focus
	connect("focus_entered", self, "set_focus")
	# disable load game if no save games available
	if GameRepository.list_save_games().empty():
		disable_button(_button_load_game)
		_last_focus = $VBoxContainer/NewGame
	else:
		_last_focus = $VBoxContainer/LoadGame
	set_focus()
	_on_focus_entered()

func set_focus():
	check_button_visibility()
	_last_focus.grab_focus()

func save_focus() -> Control:
	_last_focus = get_focus_owner()
	return _last_focus

func check_button_visibility() -> void:
	# disable load game if no save games available
	if GameRepository.list_save_games().empty():
		disable_button(_button_load_game)
	else:
		enable_button(_button_load_game)

func disable_button(button :BaseButton) -> void:
	button.disabled = true
	button.focus_mode = BaseButton.FOCUS_NONE
	button.find_node("Label").add_color_override("font_color", Color.gray)

func enable_button(button :BaseButton) -> void:
	button.disabled = false
	button.focus_mode = BaseButton.FOCUS_ALL
	button.find_node("Label").add_color_override("font_color", Color.gold)

func _on_NewGame_pressed():
	save_focus()
	add_child(_new_game.instance())

func _on_SaveGame_pressed():
	save_focus()
	add_child(_save_game.instance())

func _on_LoadGame_pressed():
	save_focus()
	add_child(_load_game.instance())

func _on_Options_pressed():
	save_focus()
	add_child(_options.instance())

func _on_Quit_pressed():
	emit_signal("game_exit")

func _on_focus_entered():
	var button = save_focus()
	if button:
		button.find_node("Label").add_color_override("font_color", Color.yellow)
		button.rect_scale.x = 1.1

func _on_focus_exited():
	if _last_focus:
		_last_focus.find_node("Label").add_color_override("font_color", Color.white)
		_last_focus.rect_scale.x = 1

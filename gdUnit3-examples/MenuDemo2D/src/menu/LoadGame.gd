extends MenuDialog

signal load_game

const COLOR_RAMP = [Color.rebeccapurple, Color.greenyellow, Color.khaki, Color.aliceblue, Color.darkorange]

onready var _itmes = $VBoxContainer/PanelContainer/HBoxContainer/ItemList
onready var _preview = $VBoxContainer/PanelContainer/HBoxContainer/preview
onready var _font = preload("res://gdUnit3-examples/MenuDemo2D/assets/menu/GameMenu-font-12.tres")

var _selected_index := -1

func _ready() -> void:
	_itmes.clear()
	_itmes.grab_focus()
	
	for game in GameRepository.list_save_games():
		_itmes.add_item(game.name())
	_itmes.select(0)
	_on_ItemList_item_selected(0)

func _on_ItemList_item_selected(index) -> void:
	_selected_index = index
	# simulate a game screen shot	
	var texture := GradientTexture.new()
	texture.set_name(_itmes.get_item_text(index))
	var gardient := Gradient.new()
	for point in range(1, index+2):
		var c = 1.0 / point
		gardient.add_point(c, COLOR_RAMP[point%5])
	texture.set_gradient(gardient)
	_preview.texture = texture

func _on_load_pressed() -> void:
	var game_to_load :String = _itmes.get_item_text(_selected_index)
	GameRepository.instance().load_game(game_to_load)
	# close self and parent menu
	get_parent()._on_ExitButton_pressed()
	_on_ExitButton_pressed()

func _on_cancel_pressed():
	_on_ExitButton_pressed()

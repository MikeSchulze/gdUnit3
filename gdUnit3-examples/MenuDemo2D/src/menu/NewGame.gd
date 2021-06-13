extends MenuDialog

onready var _new_button = $VBoxContainer/PanelContainer/HBoxContainer/new

func _ready():
	_new_button.grab_focus()

func _on_new_pressed():
	GameRepository.new_game()
	# close self and parent menu
	get_parent()._on_ExitButton_pressed()
	_on_ExitButton_pressed()

func _on_cancel_pressed():
	_on_ExitButton_pressed()

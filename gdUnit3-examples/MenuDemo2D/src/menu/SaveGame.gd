extends MenuDialog


func _on_save_pressed():
	GameRepository.save_game("game_save_%d" % GameRepository.list_save_games().size())
	# close self and parent menu
	get_parent()._on_ExitButton_pressed()
	_on_ExitButton_pressed()

func _on_cancel_pressed():
	_on_ExitButton_pressed()

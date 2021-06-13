extends CanvasLayer

signal game_paused

onready var game_menu = preload("res://gdUnit3-examples/MenuDemo2D/src/menu/GameMenu.tscn")

func open_menu():
	var menu :Node = game_menu.instance()
	menu.connect("game_exit", self, "_on_game_exit")
	menu.connect("close_dialog", self, "_on_close_menu")
	add_child(menu)
	emit_signal("game_paused", true)

func _on_close_menu(name :String):
	emit_signal("game_paused", false)
	find_node(name, true, false).queue_free()

func is_menu_open() -> bool:
	return find_node("GameMenu", true, false) != null

func _on_game_exit():
	get_tree().quit()

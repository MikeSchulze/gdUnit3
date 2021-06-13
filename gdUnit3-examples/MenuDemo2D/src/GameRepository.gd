# a fake repositors to hold save game stands
# is it a singelton class like autoload
# warning-ignore:unused_signal
class_name GameRepository
extends Reference

signal new_game
signal load_game
signal save_game

# sigleton holder
const  _instance = Array()

class GameStand:
	var _name: String
	var _time: int
	
	func _init(name :String):
		_name = name
		_time = OS.get_unix_time()
	
	func name() -> String:
		return _name

# holds saved game stands
const _save_games := Dictionary()

func _init():
	if not _instance.empty():
		assert("Singleton already instanciated!")
	_instance.append(self)

static func instance() -> GameRepository:
	if _instance.empty():
		load("res://gdUnit3-examples/MenuDemo2D/src/GameRepository.gd").new()
	return _instance[0]

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_instance.clear()
		_save_games.clear()

static func list_save_games() -> Array:
	return _save_games.values()

static func new_game() -> void:
	instance().emit_signal("new_game")

static func save_game(name: String):
	_save_games[name] = GameStand.new(name)
	instance().emit_signal("save_game", name)
	
static func load_game(name: String) -> void:
	instance().emit_signal("load_game", name)

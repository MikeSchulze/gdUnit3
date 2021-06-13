# GdUnit generated TestSuite
class_name GameMockTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://gdUnit3-examples/MenuDemo2D/src/Game.gd'

# enable only for visualisize the scene steps
var _debug_wait = false

func test_game_scene_mocked():
	var scene = mock("res://gdUnit3-examples/MenuDemo2D/src/Game.tscn")
	scene_runner(scene)
	# check inital state 
	verify(scene, 0)._on_game_paused(any_bool())
	assert_str(scene._label.text).is_equal("App started")
	assert_str(scene._state_label.text).is_equal("Game Init");
	assert_bool(scene._game_repository.is_connected("new_game", scene, "_on_new_game")).is_true()
	assert_bool(scene._game_repository.is_connected("load_game", scene, "_on_load_game")).is_true()
	assert_bool(scene._game_repository.is_connected("save_game", scene, "_on_save_game")).is_true()

func test_game_menu_open_close():
	var scene = mock("res://gdUnit3-examples/MenuDemo2D/src/Game.tscn")
	var scene_runner := scene_runner(scene)
	
	# first esc press to open the main menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	verify(scene)._on_game_paused(true)
	assert_str(scene._state_label.text).is_equal("Game Paused")
	
	# press esc again to close the game menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	verify(scene)._on_game_paused(false)
	assert_str(scene._state_label.text).is_equal("Game Running")

func test_game_menu_new_game_esc():
	var scene = mock("res://gdUnit3-examples/MenuDemo2D/src/Game.tscn")
	var scene_runner := scene_runner(scene)
	
	# simulate esc pressed to open the main menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	yield(get_tree(), "idle_frame")
	
	# game should be paused
	assert_str(scene._state_label.text).is_equal("Game Paused")
	verify(scene)._on_game_paused(true)
	if _debug_wait:
		yield(get_tree().create_timer(1), "timeout")
	
	# press enter to open create new game menu
	scene_runner.simulate_key_pressed(KEY_ENTER)
	yield(get_tree(), "idle_frame")
	if _debug_wait:
		yield(get_tree().create_timer(1), "timeout")

	# press esc to exit new game menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	yield(get_tree(), "idle_frame")
	if _debug_wait:
		yield(get_tree().create_timer(1), "timeout")
	
	# press esc back to game
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	yield(get_tree(), "idle_frame")
	if _debug_wait:
		yield(get_tree().create_timer(1), "timeout")
	
	# check the game pause is disabled and running after the main menu is closed
	verify(scene)._on_game_paused(false)
	assert_str(scene._state_label.text).is_equal("Game Running")

func test_game_menu_new_game_press_new():
	var scene = mock("res://gdUnit3-examples/MenuDemo2D/src/Game.tscn")
	var scene_runner := scene_runner(scene)
	
	# simulate esc pressed to open the main menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	yield(get_tree(), "idle_frame")
	
	# game should be paused
	assert_str(scene._state_label.text).is_equal("Game Paused")
	verify(scene)._on_game_paused(true)
	if _debug_wait:
		yield(get_tree().create_timer(1), "timeout")
	
	# press enter to open create new game menu
	scene_runner.simulate_key_pressed(KEY_ENTER)
	yield(get_tree(), "idle_frame")
	if _debug_wait:
		yield(get_tree().create_timer(1), "timeout")

	# press again enter to  create a new game
	scene_runner.simulate_key_pressed(KEY_ENTER)
	yield(get_tree(), "idle_frame")
	if _debug_wait:
		yield(get_tree().create_timer(1), "timeout")
	
	# check a new game is created an running
	verify(scene)._on_game_paused(false)
	verify(scene)._on_new_game()
	assert_str(scene._state_label.text).is_equal("Game Running")
	assert_str(scene._label.text).is_equal("Starting a new Game")

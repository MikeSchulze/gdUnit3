# GdUnit generated TestSuite
class_name GameSpyTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://gdUnit3-examples/MenuDemo2D/src/Game.gd'

# enable only for visualisize the spy_scene steps
var _debug_wait = false

var spy_scene

func before():
	# using 'before()' to create only once the spy_scene at beginning of test suite run
	var scene_instance = load("res://gdUnit3-examples/MenuDemo2D/src/Game.tscn").instance()
	# create a spy on this spy_scene instance
	spy_scene = spy(scene_instance)

func before_test():
	# reset previous recoreded interactions on this mock for each test
	reset(spy_scene)

func test_game_scene_spyed():
	scene_runner(spy_scene)
	
	# check inital state 
	verify(spy_scene, 0)._on_game_paused(any_bool())
	assert_str(spy_scene._label.text).is_equal("App started")
	assert_str(spy_scene._state_label.text).is_equal("Game Init");
	assert_bool(spy_scene._game_repository.is_connected("new_game", spy_scene, "_on_new_game")).is_true()
	
	assert_bool(spy_scene._game_repository.is_connected("new_game", spy_scene, "_on_new_game")).is_true()
	assert_bool(spy_scene._game_repository.is_connected("load_game", spy_scene, "_on_load_game")).is_true()
	assert_bool(spy_scene._game_repository.is_connected("save_game", spy_scene, "_on_save_game")).is_true()

func test_game_menu_open_close():
	var scene_runner := scene_runner(spy_scene)
	
	# first esc press to open the main menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	verify(spy_scene)._on_game_paused(true)
	assert_str(spy_scene._state_label.text).is_equal("Game Paused")
	
	# press esc again to close the game menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	verify(spy_scene)._on_game_paused(false)
	assert_str(spy_scene._state_label.text).is_equal("Game Running")

func test_game_menu_new_game_esc():
	var scene_runner := scene_runner(spy_scene)
	# simulate esc pressed to open the main menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	yield(get_tree(), "idle_frame")
	
	# game should be paused
	assert_str(spy_scene._state_label.text).is_equal("Game Paused")
	verify(spy_scene)._on_game_paused(true)
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
	verify(spy_scene)._on_game_paused(false)
	assert_str(spy_scene._state_label.text).is_equal("Game Running")

func test_game_menu_new_game_press_new():
	var scene_runner := scene_runner(spy_scene)

	# simulate esc pressed to open the main menu
	scene_runner.simulate_key_pressed(KEY_ESCAPE)
	yield(get_tree(), "idle_frame")
	
	# game should be paused
	assert_str(spy_scene._state_label.text).is_equal("Game Paused")
	verify(spy_scene)._on_game_paused(true)
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
	verify(spy_scene)._on_game_paused(false)
	verify(spy_scene)._on_new_game()
	assert_str(spy_scene._state_label.text).is_equal("Game Running")
	assert_str(spy_scene._label.text).is_equal("Starting a new Game")

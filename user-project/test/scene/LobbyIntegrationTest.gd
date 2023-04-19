# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name LobbyIntegrationTest
extends GdUnitTestSuite

# TestSuite generated from
const __prefab_source = "res://user-project/multiplayer/lobby.tscn"

var lobby_spy
var runner: GdUnitSceneRunner


# Test cases
# Before all tests are ran
func before():
	lobby_spy = spy(__prefab_source)
	runner = scene_runner(lobby_spy)


# Before each individual test is ran
func before_test():
	reset(lobby_spy)
	get_tree().set_network_peer(null)
	runner.set_time_factor(10)


func test_gamestate_host():
	var host_game_button = runner.scene().find_node("Host") as Button
	var connect_menu = runner.scene().find_node("Connect") as Panel
	var level_select_popup = runner.scene().find_node("Popup") as Popup

	prints("---1")

	assert_object(host_game_button).is_not_null()

	var mouse_position = host_game_button.rect_global_position

	runner.set_mouse_pos(mouse_position)
	yield(await_idle_frame(), "completed")
	verify(lobby_spy, 0)._on_host_pressed()

	assert_bool(connect_menu.visible).is_true()
	assert_bool(level_select_popup.visible).is_false()

	prints("---2")
	runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	yield(runner.simulate_frames(50, 10), "completed")
	verify(lobby_spy)._on_host_pressed()
	
	prints("---3")
	assert_bool(connect_menu.visible).is_false()
	assert_bool(level_select_popup.visible).is_true()



func test_2():
	var connect_menu = runner.scene().find_node("Connect") as Panel
	var level_select_popup = runner.scene().find_node("Popup") as Popup

	runner.scene()._on_host_pressed()
	
	
	assert_bool(connect_menu.visible).is_false()
	assert_bool(level_select_popup.visible).is_true()

# Helper methods


func skip_socket_connect():
	runner.scene()._on_host_pressed()

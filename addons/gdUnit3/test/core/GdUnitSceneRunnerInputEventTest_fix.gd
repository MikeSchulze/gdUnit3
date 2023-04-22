# GdUnit generated TestSuite
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitSceneRunner.gd'


var _runner :GdUnitSceneRunner
var _scene_spy :Node


func before():
	# TODO verify input position and global_position if failing when the view is shown
	OS.set_window_always_on_top(true)
	OS.set_max_window_size(Vector2(1024, 800))
	OS.set_window_maximized(true)
	OS.center_window()


func before_test():
	# reset global mouse position back to inital state
	var max_iteration_to_wait = 0
	while mouse_global_position() > Vector2.ZERO and max_iteration_to_wait < 1000:
		Input.warp_mouse_position(Vector2.ZERO)
		Input.flush_buffered_events()
		yield(await_idle_frame(), "completed")
		max_iteration_to_wait += 1
	if max_iteration_to_wait > 1:
		push_warning("Set inital global mouse pos after %d iterations" % max_iteration_to_wait)
	_scene_spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	_runner = scene_runner(_scene_spy)
	assert_inital_mouse_state()



func after_test():
	OS.window_minimized = true


func mouse_global_position() -> Vector2:
	return Engine.get_main_loop().root.get_mouse_position()



#asserts to Mouse ButtonList Enums
func assert_inital_mouse_state():
	for button in [
		BUTTON_LEFT,
		BUTTON_MIDDLE,
		BUTTON_RIGHT,
		BUTTON_XBUTTON1,
		BUTTON_XBUTTON2,
		BUTTON_WHEEL_UP,
		BUTTON_WHEEL_DOWN,
		BUTTON_WHEEL_LEFT,
		BUTTON_WHEEL_RIGHT,
		]:
		assert_that(Input.is_mouse_button_pressed(button)).is_false()
	assert_that(Input.get_mouse_button_mask()).is_equal(0)
	assert_that(mouse_global_position()).is_equal(Vector2.ZERO)


func test_set_mouse_vs_global_mouse_pos() -> void:
	for mp in [Vector2(0, 0), Vector2(300, 400), Vector2(120, 100), Vector2(0, 0)]:
		Input.set_use_accumulated_input(false)
		var max_iteration_to_wait = 0
		while mouse_global_position() != mp and max_iteration_to_wait < 100:
			Input.warp_mouse_position(mp)
			
			#Input.flush_buffered_events()
			yield(await_idle_frame(), "completed")
			max_iteration_to_wait += 1
			
		var mouse_pos := get_viewport().get_mouse_position()
		prints("current mouse pos: %s" % mouse_pos)
		assert_that(mouse_pos).is_equal(mp)


func test_simulate_set_mouse_pos():
	# set mouse to pos 100, 100
	prints("set mouse to pos 100, 100: global: %s" % mouse_global_position())
	var expected_event := InputEventMouseMotion.new()
	expected_event.position = Vector2(100, 100)
	expected_event.global_position = mouse_global_position()
	_runner.set_mouse_pos(Vector2(100, 100))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 1)._input(expected_event)
	
	# set mouse to pos 800, 400
	prints("set mouse to pos 800, 400: global: %s" % mouse_global_position())
	expected_event = InputEventMouseMotion.new()
	expected_event.position = Vector2(800, 400)
	expected_event.global_position = mouse_global_position()
	_runner.set_mouse_pos(Vector2(800, 400))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 1)._input(expected_event)
	
	# and again back to 100,100
	prints("set mouse to pos 100,100: global: %s" % mouse_global_position())
	expected_event = InputEventMouseMotion.new()
	expected_event.position = Vector2(100, 100)
	expected_event.global_position = mouse_global_position()
	_runner.set_mouse_pos(Vector2(100, 100))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 2)._input(expected_event)

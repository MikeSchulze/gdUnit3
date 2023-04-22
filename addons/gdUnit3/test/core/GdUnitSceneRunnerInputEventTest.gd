# GdUnit generated TestSuite
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitSceneRunner.gd'


var _runner :GdUnitSceneRunner
var _scene_spy :Node


func _before():
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
		yield(await_idle_frame(), "completed")
		max_iteration_to_wait += 1
	if max_iteration_to_wait > 1:
		push_warning("Set inital global mouse pos after %d iterations" % max_iteration_to_wait)
	_scene_spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	_runner = scene_runner(_scene_spy)
	assert_inital_mouse_state()
	assert_inital_key_state()


func after_test():
	OS.window_minimized = true


func mouse_global_position() -> Vector2:
	return get_tree().root.get_mouse_position()


# asserts to KeyList Enums
func assert_inital_key_state():
	# scacode 16777217-16777319
	for key in range(KEY_ESCAPE, KEY_LAUNCHF):
		assert_that(Input.is_key_pressed(key)).is_false()
		assert_that(Input.is_physical_key_pressed(key)).is_false()
	# scancode 32-255
	for key in range(KEY_SPACE, KEY_YDIAERESIS):
		assert_that(Input.is_key_pressed(key)).is_false()
		assert_that(Input.is_physical_key_pressed(key)).is_false()


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


func test_reset_to_inital_state_on_release():
	var runner = scene_runner("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	# simulate mouse buttons and key press but we never released it
	runner.simulate_mouse_button_press(BUTTON_LEFT)
	runner.simulate_mouse_button_press(BUTTON_RIGHT)
	runner.simulate_mouse_button_press(BUTTON_MIDDLE)
	runner.simulate_key_press(KEY_0)
	runner.simulate_key_press(KEY_X)
	yield(await_idle_frame(), "completed")
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_true()
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_true()
	assert_that(Input.is_mouse_button_pressed(BUTTON_MIDDLE)).is_true()
	assert_that(Input.is_key_pressed(KEY_0)).is_true()
	assert_that(Input.is_key_pressed(KEY_X)).is_true()
	# free the scene runner to enforce reset to initial Input state
	runner.free()
	yield(await_idle_frame(), "completed")
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_false()
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_false()
	assert_that(Input.is_mouse_button_pressed(BUTTON_MIDDLE)).is_false()
	assert_that(Input.is_key_pressed(KEY_0)).is_false()
	assert_that(Input.is_key_pressed(KEY_X)).is_false()


func test_simulate_key_press() -> void:
	# iterate over some example keys
	for key in [KEY_A, KEY_D, KEY_X, KEY_0]:
		_runner.simulate_key_press(key)
		yield(await_idle_frame(), "completed")
		
		var event := InputEventKey.new()
		event.scancode = key
		event.physical_scancode = key
		event.pressed = true
		verify(_scene_spy, 1)._input(event)
		assert_that(Input.is_key_pressed(key)).is_true()
	# verify all this keys are still handled as pressed
	assert_that(Input.is_key_pressed(KEY_A)).is_true()
	assert_that(Input.is_key_pressed(KEY_D)).is_true()
	assert_that(Input.is_key_pressed(KEY_X)).is_true()
	assert_that(Input.is_key_pressed(KEY_0)).is_true()
	# other keys are not pressed
	assert_that(Input.is_key_pressed(KEY_B)).is_false()
	assert_that(Input.is_key_pressed(KEY_G)).is_false()
	assert_that(Input.is_key_pressed(KEY_Z)).is_false()
	assert_that(Input.is_key_pressed(KEY_1)).is_false()


func test_simulate_key_press_with_modifiers() -> void:
	# press shift key + A
	_runner.simulate_key_press(KEY_SHIFT)
	_runner.simulate_key_press(KEY_A)
	yield(await_idle_frame(), "completed")
	
	# results in two events, first is the shift key is press
	var event := InputEventKey.new()
	event.scancode = KEY_SHIFT
	event.physical_scancode = KEY_SHIFT
	event.pressed = true
	event.shift = true
	verify(_scene_spy, 1)._input(event)
	
	# second is the comnbination of current press shift and key A
	event = InputEventKey.new()
	event.scancode = KEY_A
	event.physical_scancode = KEY_A
	event.pressed = true
	event.shift = true
	verify(_scene_spy, 1)._input(event)
	assert_that(Input.is_key_pressed(KEY_SHIFT)).is_true()
	assert_that(Input.is_key_pressed(KEY_A)).is_true()


func test_simulate_many_keys_press() -> void:
	# press and hold keys W and Z
	_runner.simulate_key_press(KEY_W)
	_runner.simulate_key_press(KEY_Z)
	yield(await_idle_frame(), "completed")
	
	assert_that(Input.is_key_pressed(KEY_W)).is_true()
	assert_that(Input.is_physical_key_pressed(KEY_W)).is_true()
	assert_that(Input.is_key_pressed(KEY_Z)).is_true()
	assert_that(Input.is_physical_key_pressed(KEY_Z)).is_true()
	
	#now release key w
	_runner.simulate_key_release(KEY_W)
	yield(await_idle_frame(), "completed")
	
	assert_that(Input.is_key_pressed(KEY_W)).is_false()
	assert_that(Input.is_physical_key_pressed(KEY_W)).is_false()
	assert_that(Input.is_key_pressed(KEY_Z)).is_true()
	assert_that(Input.is_physical_key_pressed(KEY_Z)).is_true()


func test_simulate_set_mouse_pos():
	# set mouse to pos 100, 100
	var expected_event := InputEventMouseMotion.new()
	expected_event.position = Vector2(100, 100)
	expected_event.global_position = mouse_global_position()
	_runner.set_mouse_pos(Vector2(100, 100))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 1)._input(expected_event)
	
	# set mouse to pos 800, 400
	expected_event = InputEventMouseMotion.new()
	expected_event.position = Vector2(800, 400)
	expected_event.global_position = mouse_global_position()
	_runner.set_mouse_pos(Vector2(800, 400))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 1)._input(expected_event)
	
	# and again back to 100,100
	expected_event = InputEventMouseMotion.new()
	expected_event.position = Vector2(100, 100)
	expected_event.global_position = mouse_global_position()
	_runner.set_mouse_pos(Vector2(100, 100))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 2)._input(expected_event)


func test_simulate_set_mouse_pos_with_modifiers():
	var is_alt := false
	var is_control := false
	var is_shift := false
	
	for modifier in [KEY_SHIFT, KEY_CONTROL, KEY_ALT]:
		is_alt = is_alt or KEY_ALT == modifier
		is_control = is_control or KEY_CONTROL == modifier
		is_shift = is_shift or KEY_SHIFT == modifier
		
		for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
			var expected_event := InputEventMouseButton.new()
			expected_event.position = Vector2(10, 10)
			expected_event.global_position = mouse_global_position()
			expected_event.alt = is_alt
			expected_event.control = is_control
			expected_event.shift = is_shift
			expected_event.pressed = true
			expected_event.button_index = mouse_button
			expected_event.button_mask = GdUnitSceneRunnerImpl.MAP_MOUSE_BUTTON_MASKS.get(mouse_button)
			
			# simulate press shift, set mouse pos and final press mouse button
			_runner.simulate_key_press(modifier)
			_runner.set_mouse_pos(Vector2(10, 10))
			_runner.simulate_mouse_button_press(mouse_button)
			yield(await_idle_frame(), "completed")
		
			verify(_scene_spy, 1)._input(expected_event)
			assert_that(Input.is_mouse_button_pressed(mouse_button)).is_true()
			# finally release it
			_runner.simulate_mouse_button_pressed(mouse_button)
			yield(await_idle_frame(), "completed")


func test_simulate_mouse_move():
	var expected_event = InputEventMouseMotion.new()
	expected_event.position = Vector2(400, 100)
	expected_event.global_position = mouse_global_position()
	expected_event.relative = Vector2(400, 100) - Vector2(10, 10)
	_runner.set_mouse_pos(Vector2(10, 10))
	_runner.simulate_mouse_move(Vector2(400, 100))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 1)._input(expected_event)
	
	# move mouse to next pos
	expected_event = InputEventMouseMotion.new()
	expected_event.position = Vector2(55, 42)
	expected_event.global_position = mouse_global_position()
	expected_event.relative = Vector2(55, 42) - Vector2(400, 100)
	_runner.simulate_mouse_move(Vector2(55, 42))
	yield(await_idle_frame(), "completed")
	verify(_scene_spy, 1)._input(expected_event)


func test_simulate_mouse_move_relative():
	#OS.window_minimized = false
	_runner.set_mouse_pos(Vector2(10, 10))
	yield(await_idle_frame(), "completed")
	#assert_that(_runner.get_mouse_position()).is_equal(Vector2(10, 10))
	
	yield(_runner.simulate_mouse_move_relative(Vector2(900, 400), Vector2(.2, 1)), "completed")
	yield(await_idle_frame(), "completed")
	assert_that(_runner.get_mouse_position()).is_equal(Vector2(910, 410))


func test_simulate_mouse_button_press_left():
	var expected_event := InputEventMouseButton.new()
	expected_event.position = Vector2.ZERO
	expected_event.global_position = mouse_global_position()
	expected_event.pressed = true
	expected_event.button_index = BUTTON_LEFT
	expected_event.button_mask = GdUnitSceneRunnerImpl.MAP_MOUSE_BUTTON_MASKS.get(BUTTON_LEFT)
	# simulate mouse button press and hold
	_runner.simulate_mouse_button_press(BUTTON_LEFT)
	yield(await_idle_frame(), "completed")
	
	verify(_scene_spy, 1)._input(expected_event)
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_true()


func test_simulate_mouse_button_press_left_doubleclick():
	var expected_event := InputEventMouseButton.new()
	expected_event.position = Vector2.ZERO
	expected_event.global_position = mouse_global_position()
	expected_event.pressed = true
	expected_event.doubleclick = true
	expected_event.button_index = BUTTON_LEFT
	expected_event.button_mask = GdUnitSceneRunnerImpl.MAP_MOUSE_BUTTON_MASKS.get(BUTTON_LEFT)
	# simulate mouse button press doubleclick
	_runner.simulate_mouse_button_press(BUTTON_LEFT, true)
	yield(await_idle_frame(), "completed")
	
	verify(_scene_spy, 1)._input(expected_event)
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_true()


func test_simulate_mouse_button_press_right():
	var expected_event := InputEventMouseButton.new()
	expected_event.position = Vector2.ZERO
	expected_event.global_position = mouse_global_position()
	expected_event.pressed = true
	expected_event.button_index = BUTTON_RIGHT
	expected_event.button_mask = GdUnitSceneRunnerImpl.MAP_MOUSE_BUTTON_MASKS.get(BUTTON_RIGHT)
	# simulate mouse button press and hold
	_runner.simulate_mouse_button_press(BUTTON_RIGHT)
	yield(await_idle_frame(), "completed")
	
	verify(_scene_spy, 1)._input(expected_event)
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_true()


func test_simulate_mouse_button_press_left_and_right():
	# results in two events, first is left mouse button
	var expected_event1 := InputEventMouseButton.new()
	expected_event1.position = Vector2.ZERO
	expected_event1.global_position = mouse_global_position()
	expected_event1.pressed = true
	expected_event1.button_index = BUTTON_LEFT
	expected_event1.button_mask = BUTTON_MASK_LEFT
	# second is left+right and combined mask
	var expected_event2 = InputEventMouseButton.new()
	expected_event2.position = Vector2.ZERO
	expected_event2.global_position = mouse_global_position()
	expected_event2.pressed = true
	expected_event2.button_index = BUTTON_RIGHT
	expected_event2.button_mask = BUTTON_MASK_LEFT|BUTTON_MASK_RIGHT
	
	# simulate mouse button press left+right
	_runner.simulate_mouse_button_press(BUTTON_LEFT)
	_runner.simulate_mouse_button_press(BUTTON_RIGHT)
	yield(await_idle_frame(), "completed")
	
	verify(_scene_spy, 1)._input(expected_event1)
	verify(_scene_spy, 1)._input(expected_event2)
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_true()
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_true()
	assert_that(Input.get_mouse_button_mask()).is_equal(BUTTON_MASK_LEFT|BUTTON_MASK_RIGHT)


func test_simulate_mouse_button_press_left_and_right_and_release():
	# will results into two events
	# first for left mouse button
	var expected_event1 := InputEventMouseButton.new()
	expected_event1.position = Vector2.ZERO
	expected_event1.global_position = mouse_global_position()
	expected_event1.pressed = true
	expected_event1.button_index = BUTTON_LEFT
	expected_event1.button_mask = BUTTON_MASK_LEFT
	# second is left+right and combined mask
	var expected_event2 = InputEventMouseButton.new()
	expected_event2.position = Vector2.ZERO
	expected_event2.global_position = mouse_global_position()
	expected_event2.pressed = true
	expected_event2.button_index = BUTTON_RIGHT
	expected_event2.button_mask = BUTTON_MASK_LEFT|BUTTON_MASK_RIGHT
	
	# simulate mouse button press left+right
	_runner.simulate_mouse_button_press(BUTTON_LEFT)
	_runner.simulate_mouse_button_press(BUTTON_RIGHT)
	yield(await_idle_frame(), "completed")
	
	verify(_scene_spy, 1)._input(expected_event1)
	verify(_scene_spy, 1)._input(expected_event2)
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_true()
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_true()
	assert_that(Input.get_mouse_button_mask()).is_equal(BUTTON_MASK_LEFT|BUTTON_MASK_RIGHT)
	
	# now release the right button
	var expected_event = InputEventMouseButton.new()
	expected_event.position = Vector2.ZERO
	expected_event.global_position = mouse_global_position()
	expected_event.pressed = false
	expected_event.button_index = BUTTON_RIGHT
	expected_event.button_mask = BUTTON_MASK_LEFT
	_runner.simulate_mouse_button_pressed(BUTTON_RIGHT)
	yield(await_idle_frame(), "completed")
	# will result in right button press false but stay with mask for left pressed

	verify(_scene_spy, 1)._input(expected_event)
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_true()
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_false()
	assert_that(Input.get_mouse_button_mask()).is_equal(BUTTON_MASK_LEFT)
	
	
	# finally relase left button
	# will result in right button press false but stay with mask for left pressed
	expected_event = InputEventMouseButton.new()
	expected_event.position = Vector2.ZERO
	expected_event.global_position = mouse_global_position()
	expected_event.pressed = false
	expected_event.button_index = BUTTON_LEFT
	expected_event.button_mask = 0
	_runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	yield(await_idle_frame(), "completed")

	verify(_scene_spy, 1)._input(expected_event)
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_false()
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_false()
	assert_that(Input.get_mouse_button_mask()).is_equal(0)


func test_simulate_mouse_button_pressed():
	for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
		# simulate mouse button press and release
		# it genrates two events, first for press and second as released
		var expected_event1 := InputEventMouseButton.new()
		expected_event1.position = Vector2.ZERO
		expected_event1.global_position = mouse_global_position()
		expected_event1.pressed = true
		expected_event1.button_index = mouse_button
		expected_event1.button_mask = GdUnitSceneRunnerImpl.MAP_MOUSE_BUTTON_MASKS.get(mouse_button)
		
		var expected_event2 = InputEventMouseButton.new()
		expected_event2.position = Vector2.ZERO
		expected_event2.global_position = mouse_global_position()
		expected_event2.pressed = false
		expected_event2.button_index = mouse_button
		expected_event2.button_mask = 0
		
		_runner.simulate_mouse_button_pressed(mouse_button)
		yield(await_idle_frame(), "completed")
		
		verify(_scene_spy, 1)._input(expected_event1)
		verify(_scene_spy, 1)._input(expected_event2)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_false()
		verify(_scene_spy, 2)._input(any_class(InputEventMouseButton))
		reset(_scene_spy)


func test_simulate_mouse_button_pressed_doubleclick():
	for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
		# simulate mouse button press and release by doubleclick
		# it genrates two events, first for press and second as released
		var expected_event1 := InputEventMouseButton.new()
		expected_event1.position = Vector2.ZERO
		expected_event1.global_position = mouse_global_position()
		expected_event1.pressed = true
		expected_event1.doubleclick = true
		expected_event1.button_index = mouse_button
		expected_event1.button_mask = GdUnitSceneRunnerImpl.MAP_MOUSE_BUTTON_MASKS.get(mouse_button)
		var expected_event2 = InputEventMouseButton.new()
		expected_event2.position = Vector2.ZERO
		expected_event2.global_position = mouse_global_position()
		expected_event2.pressed = false
		expected_event2.doubleclick = false
		expected_event2.button_index = mouse_button
		expected_event2.button_mask = 0
		_runner.simulate_mouse_button_pressed(mouse_button, true)
		yield(await_idle_frame(), "completed")
		
		verify(_scene_spy, 1)._input(expected_event1)
		verify(_scene_spy, 1)._input(expected_event2)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_false()
		verify(_scene_spy, 2)._input(any_class(InputEventMouseButton))
		reset(_scene_spy)

func test_simulate_mouse_button_press_and_release():
	for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
		# simulate mouse button press and release
		var expected_event := InputEventMouseButton.new()
		expected_event.position = Vector2.ZERO
		expected_event.global_position = mouse_global_position()
		expected_event.pressed = true
		expected_event.button_index = mouse_button
		expected_event.button_mask = GdUnitSceneRunnerImpl.MAP_MOUSE_BUTTON_MASKS.get(mouse_button)
		_runner.simulate_mouse_button_press(mouse_button)
		yield(await_idle_frame(), "completed")
		
		verify(_scene_spy, 1)._input(expected_event)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_true()
		
		# now simulate mouse button release
		expected_event = InputEventMouseButton.new()
		expected_event.position = Vector2.ZERO
		expected_event.global_position = mouse_global_position()
		expected_event.pressed = false
		expected_event.button_index = mouse_button
		expected_event.button_mask = 0
		_runner.simulate_mouse_button_release(mouse_button)
		yield(await_idle_frame(), "completed")
		
		verify(_scene_spy, 1)._input(expected_event)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_false()

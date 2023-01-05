# GdUnit generated TestSuite
class_name GdUnitSceneRunnerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitSceneRunner.gd'

# loads the test runner and register for auto freeing after test 
func load_test_scene() -> Node:
	return auto_free(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())


func before():
	# use a dedicated FPS because we calculate frames by time
	Engine.set_target_fps(60)

func after():
	Engine.set_target_fps(0)

func test_get_property() -> void:
	var runner := scene_runner(load_test_scene())
	
	assert_that(runner.get_property("_box1")).is_instanceof(ColorRect)
	assert_that(runner.get_property("_invalid")).is_equal("The property '_invalid' not exist on loaded scene.")

func test_invoke_method() -> void:
	var runner := scene_runner(load_test_scene())
	
	assert_that(runner.invoke("add", 10, 12)).is_equal(22)
	assert_that(runner.invoke("sub", 10, 12)).is_equal("The method 'sub' not exist on loaded scene.")

func test_awaitForMilliseconds() -> void:
	var runner := scene_runner(load_test_scene())
	
	var stopwatch = LocalTime.now()
	yield(await_millis(1000), "completed")
	
	# verify we wait around 1000 ms (using 100ms offset because timing is not 100% accurate)
	assert_int(stopwatch.elapsed_since_ms()).is_between(900, 1100)

func test_simulate_frames(timeout = 5000) -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# initial is white
	assert_object(box1.color).is_equal(Color.white)
	
	# start color cycle by invoke the function 'start_color_cycle'
	runner.invoke("start_color_cycle")
	
	# we wait for 10 frames
	yield(runner.simulate_frames(10), "completed")
	# after 10 frame is still white
	assert_object(box1.color).is_equal(Color.white)
	
	# we wait 30 more frames
	yield(runner.simulate_frames(30), "completed")
	# after 40 frames the box one should be changed to red
	assert_object(box1.color).is_equal(Color.red)

func test_simulate_frames_withdelay(timeout = 4000) -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# initial is white
	assert_object(box1.color).is_equal(Color.white)
	
	# start color cycle by invoke the function 'start_color_cycle'
	runner.invoke("start_color_cycle")
	
	# we wait for 10 frames each with a 50ms delay
	yield(runner.simulate_frames(10, 50), "completed")
	# after 10 frame and in sum 500ms is should be changed to red
	assert_object(box1.color).is_equal(Color.red)

func test_run_scene_colorcycle(timeout=2000) -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# verify inital color
	assert_object(box1.color).is_equal(Color.white)
	
	# start color cycle by invoke the function 'start_color_cycle'
	runner.invoke("start_color_cycle")
	
	# await for each color cycle is emited
	yield(runner.await_signal("panel_color_change", [box1, Color.red]), "completed")
	assert_object(box1.color).is_equal(Color.red)
	yield(runner.await_signal("panel_color_change", [box1, Color.blue]), "completed")
	assert_object(box1.color).is_equal(Color.blue)
	yield(runner.await_signal("panel_color_change", [box1, Color.green]), "completed")
	assert_object(box1.color).is_equal(Color.green)

func test_simulate_key_press() -> void:
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spy)
	# iterate over some example keys
	for key in [KEY_A, KEY_D, KEY_X, KEY_0]:
		runner.simulate_key_press(key)
		yield(await_idle_frame(), "completed")
		
		var event := InputEventKey.new()
		event.scancode = key
		event.physical_scancode = key
		event.pressed = true
		verify(spy, 1)._input(event)
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
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spy)
	
	# press shift key + A
	runner.simulate_key_press(KEY_SHIFT)
	runner.simulate_key_press(KEY_A)
	yield(await_idle_frame(), "completed")
	
	var event := InputEventKey.new()
	event.scancode = KEY_A
	event.physical_scancode = KEY_A
	event.pressed = true
	event.shift = true
	verify(spy, 1)._input(event)
	assert_that(Input.is_key_pressed(KEY_SHIFT)).is_true()
	assert_that(Input.is_key_pressed(KEY_A)).is_true()


func test_simulate_many_keys_press() -> void:
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spy)
	
	# press and hold keys W and Z
	runner.simulate_key_press(KEY_W)
	runner.simulate_key_press(KEY_Z)
	yield(await_idle_frame(), "completed")
	
	assert_that(Input.is_key_pressed(KEY_W)).is_true()
	assert_that(Input.is_physical_key_pressed(KEY_W)).is_true()
	assert_that(Input.is_key_pressed(KEY_Z)).is_true()
	assert_that(Input.is_physical_key_pressed(KEY_Z)).is_true()
	
	#now release key w
	runner.simulate_key_release(KEY_W)
	yield(await_idle_frame(), "completed")
	
	assert_that(Input.is_key_pressed(KEY_W)).is_false()
	assert_that(Input.is_physical_key_pressed(KEY_W)).is_false()
	assert_that(Input.is_key_pressed(KEY_Z)).is_true()
	assert_that(Input.is_physical_key_pressed(KEY_Z)).is_true()

func test_simulate_scene_intearction_by_press_enter(timeout=2000) -> void:
	var runner := scene_runner(load_test_scene())
	
	# inital no spell is fired
	assert_object(runner.find_node("Spell")).is_null()
	
	# fire spell be pressing enter key
	runner.simulate_key_pressed(KEY_ENTER)
	# wait until next frame
	yield(await_idle_frame(), "completed")
	
	# verify a spell is created
	assert_object(runner.find_node("Spell")).is_not_null()
	
	# wait until spell is explode after around 1s
	var spell = runner.find_node("Spell")
	yield(await_signal_on(spell, "spell_explode", [spell]), "completed")
	
	# verify spell is removed when is explode
	assert_object(runner.find_node("Spell")).is_null()

# mock on a runner and spy on created spell
func test_simulate_key_pressed_in_combination_with_spy():
	var mocked_scene :Control = mock("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	assert_object(mocked_scene).is_not_null()
	# create a runner runner
	var runner := scene_runner(mocked_scene)
	
	# unsing spy to overwrite _create_spell() to spy on the spell
	var spell :Spell = auto_free(Spell.new())
	var spell_spy :Spell = spy(spell)
	do_return(spell_spy).on(mocked_scene)._create_spell()
	
	# simulate a key event to fire a spell
	runner.simulate_key_pressed(KEY_ENTER)
	yield(await_idle_frame(), "completed")
	verify(mocked_scene).create_spell()
	verify(mocked_scene).add_child(spell_spy)
	verify(spell_spy).connect("spell_explode", mocked_scene, "_destroy_spell")

func test_reset_to_inital_state_on_release():
	var runner := scene_runner("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	
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
	
	# free the scene runner to enforce restet global Input state
	runner.free()
	yield(await_idle_frame(), "completed")
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_false()
	assert_that(Input.is_mouse_button_pressed(BUTTON_RIGHT)).is_false()
	assert_that(Input.is_mouse_button_pressed(BUTTON_MIDDLE)).is_false()
	assert_that(Input.is_key_pressed(KEY_0)).is_false()
	assert_that(Input.is_key_pressed(KEY_X)).is_false()

func test_simulate_set_mouse_pos():
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner = scene_runner(spy)
	
	# set mouse to pos 100, 100
	runner.set_mouse_pos(Vector2(100, 100))
	yield(await_idle_frame(), "completed")
	var event := InputEventMouseMotion.new()
	event.position = Vector2(100, 100)
	event.global_position = get_tree().root.get_mouse_position()
	verify(spy, 1)._input(event)
	
	# set mouse to pos 800, 400
	runner.set_mouse_pos(Vector2(800, 400))
	yield(await_idle_frame(), "completed")
	event = InputEventMouseMotion.new()
	event.position = Vector2(800, 400)
	event.global_position = get_tree().root.get_mouse_position()
	verify(spy, 1)._input(event)
	
	# and again back to 100,100
	runner.set_mouse_pos(Vector2(100, 100))
	yield(await_idle_frame(), "completed")
	event = InputEventMouseMotion.new()
	event.position = Vector2(100, 100)
	event.global_position = get_tree().root.get_mouse_position()
	verify(spy, 2)._input(event)

func test_simulate_mouse_button_press():
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spy)
	
	for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
		# simulate mouse button press and hold
		runner.simulate_mouse_button_press(mouse_button)
		yield(await_idle_frame(), "completed")
		
		var event := InputEventMouseButton.new()
		event.position = Vector2.ZERO
		event.pressed = true
		event.button_index = mouse_button
		event.button_mask = mouse_button
		verify(spy, 1)._input(event)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_true()

func test_simulate_mouse_button_pressed():
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spy)
	
	for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
		# simulate mouse button press and release
		runner.simulate_mouse_button_pressed(mouse_button)
		yield(await_idle_frame(), "completed")
		
		var event := InputEventMouseButton.new()
		event.position = Vector2.ZERO
		event.pressed = true
		event.button_index = mouse_button
		event.button_mask = mouse_button
		verify(spy, 1)._input(event)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_false()

func test_simulate_mouse_button_press_and_release():
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spy)
	
	for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
		# simulate mouse button press and release
		runner.simulate_mouse_button_press(mouse_button)
		yield(await_idle_frame(), "completed")
		
		var event := InputEventMouseButton.new()
		event.position = Vector2.ZERO
		event.pressed = true
		event.button_index = mouse_button
		event.button_mask = mouse_button
		verify(spy, 1)._input(event)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_true()
		
		# now simulate mouse button release
		runner.simulate_mouse_button_release(mouse_button)
		yield(await_idle_frame(), "completed")
		
		event = InputEventMouseButton.new()
		event.position = Vector2.ZERO
		event.pressed = true
		event.button_index = mouse_button
		event.button_mask = mouse_button
		verify(spy, 1)._input(event)
		assert_that(Input.is_mouse_button_pressed(mouse_button)).is_false()

func test_simulate_set_mouse_pos_with_modifiers():
	var spy = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spy)
	assert_that(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_false()
	
	var is_alt := false
	var is_control := false
	var is_shift := false
	
	for modifier in [KEY_SHIFT, KEY_CONTROL, KEY_ALT]:
		is_alt = is_alt or KEY_ALT == modifier
		is_control = is_control or KEY_CONTROL == modifier
		is_shift = is_shift or KEY_SHIFT == modifier
		
		for mouse_button in [BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT]:
			# simulate press shift, set mouse pos and final press mouse button
			runner.simulate_key_press(modifier)
			runner.set_mouse_pos(Vector2(10, 10))
			runner.simulate_mouse_button_press(mouse_button)
			yield(await_idle_frame(), "completed")
			
			var event := InputEventMouseButton.new()
			event.position = Vector2(10, 10)
			event.alt = is_alt
			event.control = is_control
			event.shift = is_shift
			event.pressed = true
			event.button_index = mouse_button
			event.button_mask = mouse_button
			verify(spy, 1)._input(event)
			assert_that(Input.is_mouse_button_pressed(mouse_button)).is_true()

func test_simulate_mouse_move():
	var spyed_scene = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spyed_scene)
	runner.maximize_view()
	
	# save inital global mouse pos
	var global_mouse_pos := get_tree().root.get_mouse_position()
	
	runner.set_mouse_pos(Vector2(10, 10))
	runner.simulate_mouse_move(Vector2(400, 100))
	yield(await_idle_frame(), "completed")
	
	var event = InputEventMouseMotion.new()
	event.position = Vector2(400, 100)
	event.global_position = global_mouse_pos
	event.relative = event.position - global_mouse_pos
	verify(spyed_scene, 1)._input(event)
	
	# move mouse to next pos
	global_mouse_pos = get_tree().root.get_mouse_position()
	runner.simulate_mouse_move(Vector2(55, 42))
	yield(await_idle_frame(), "completed")
	
	event = InputEventMouseMotion.new()
	event.position = Vector2(55, 42)
	event.global_position = global_mouse_pos
	event.relative = event.position - global_mouse_pos
	verify(spyed_scene, 1)._input(event)

func _test_simulate_mouse_move_relative():
	var spyed_scene = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spyed_scene)
	runner.maximize_view()
	runner.set_mouse_pos(Vector2(10, 10))
	runner.simulate_mouse_move_relative(Vector2(400, 100))
	while not Engine.get_main_loop().is_input_handled():
		yield(runner.simulate_frames(1), "completed")
	assert_that(get_viewport().get_mouse_position()).is_equal(Vector2(410, 110))


func test_simulate_mouse_events():
	var spyed_scene = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spyed_scene)
	
	# test button 1 interaction
	runner.set_mouse_pos(Vector2(60, 20))
	runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	yield(await_idle_frame(), "completed")
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box1, Color.red)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box1, Color.gray)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box2, any_color())
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, any_color())
	
	# test button 2 interaction
	reset(spyed_scene)
	runner.set_mouse_pos(Vector2(160, 20))
	runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	yield(await_idle_frame(), "completed")
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box1, any_color())
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box2, Color.red)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box2, Color.gray)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, any_color())
	
	# test button 3 interaction (is changed after 1s to gray)
	reset(spyed_scene)
	runner.set_mouse_pos(Vector2(260, 20))
	runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	yield(await_idle_frame(), "completed")
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box1, any_color())
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box2, any_color())
	# is changed to red
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box3, Color.red)
	# no gray
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, Color.gray)
	# after one second is changed to gray
	yield(await_millis(1200), "completed")
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box3, Color.gray)

func test_await_func_without_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	
	yield(runner.await_func("color_cycle").is_equal("black"), "completed")
	yield(runner.await_func("color_cycle", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_equal("red"), "completed")\
		.has_failure_message("Expected: is equal 'red' but timed out after 500ms")

func test_await_func_with_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	
	# set max time factor to minimize waiting time on `runner.wait_func`
	runner.set_time_factor(10)
	yield(runner.await_func("color_cycle").wait_until(200).is_equal("black"), "completed")
	yield(runner.await_func("color_cycle", [], GdUnitAssert.EXPECT_FAIL).wait_until(100).is_equal("red"), "completed")\
		.has_failure_message("Expected: is equal 'red' but timed out after 100ms")

func test_await_signal_without_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	
	runner.invoke("start_color_cycle")
	yield(runner.await_signal("panel_color_change", [box1, Color.red]), "completed")
	yield(runner.await_signal("panel_color_change", [box1, Color.blue]), "completed")
	yield(runner.await_signal("panel_color_change", [box1, Color.green]), "completed")
	
	# should be interrupted is will never change to Color.khaki
	GdAssertReports.expect_fail()
	yield(runner.await_signal( "panel_color_change", [box1, Color.khaki], 300), "completed")
	if assert_failed_at(451, "await_signal_on(panel_color_change, [%s, %s]) timed out after 300ms" % [str(box1), str(Color.khaki)]):
		return
	fail("test should failed after 300ms on 'await_signal'")

func test_await_signal_with_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# set max time factor to minimize waiting time on `runner.wait_func`
	runner.set_time_factor(10)
	runner.invoke("start_color_cycle")
	
	yield(runner.await_signal("panel_color_change", [box1, Color.red], 100), "completed")
	yield(runner.await_signal("panel_color_change", [box1, Color.blue], 100), "completed")
	yield(runner.await_signal("panel_color_change", [box1, Color.green], 100), "completed")
	
	# should be interrupted is will never change to Color.khaki
	GdAssertReports.expect_fail()
	yield(runner.await_signal("panel_color_change", [box1, Color.khaki], 30), "completed")
	if assert_failed_at(469, "await_signal_on(panel_color_change, [%s, %s]) timed out after 30ms" % [str(box1), str(Color.khaki)]):
		return
	fail("test should failed after 30ms on 'await_signal'")

func test_simulate_until_signal() -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	
	# set max time factor to minimize waiting time on `runner.wait_func`
	runner.invoke("start_color_cycle")
	
	yield(runner.simulate_until_signal("panel_color_change", box1, Color.red), "completed")
	yield(runner.simulate_until_signal("panel_color_change", box1, Color.blue), "completed")
	yield(runner.simulate_until_signal("panel_color_change", box1, Color.green), "completed")
	#yield(runner.wait_emit_signal(runner, "panel_color_change", [runner._box1, Color.khaki], 30, GdUnitAssert.EXPECT_FAIL), "completed")\
	#	.starts_with_failure_message("Expecting emit signal: 'panel_color_change(")

func test_simulate_until_object_signal(timeout=2000) -> void:
	var runner := scene_runner(load_test_scene())
	
	# inital no spell is fired
	assert_object(runner.find_node("Spell")).is_null()
	
	# fire spell be pressing enter key
	runner.simulate_key_pressed(KEY_ENTER)
	# wait until next frame
	yield(await_idle_frame(), "completed")
	var spell = runner.find_node("Spell")
	
	# simmulate scene until the spell is explode
	yield(runner.simulate_until_object_signal(spell, "spell_explode", spell), "completed")
	
	# verify spell is removed when is explode
	assert_object(runner.find_node("Spell")).is_null()

func test_runner_by_null_instance() -> void:
	var runner := scene_runner(null)
	assert_object(runner.scene()).is_null()

func test_runner_by_invalid_resource_path() -> void:
	# not existing scene
	assert_object(scene_runner("res://test_scene.tscn").scene()).is_null()
	# not a path to a scene
	assert_object(scene_runner("res://addons/gdUnit3/test/core/resources/scenes/simple_scene.gd").scene()).is_null()

func test_runner_by_resource_path() -> void:
	var runner = scene_runner("res://addons/gdUnit3/test/core/resources/scenes/simple_scene.tscn")
	assert_object(runner.scene()).is_instanceof(Node2D)
	
	# verify the scene is freed when the runner is freed
	var scene = runner.scene()
	assert_bool(is_instance_valid(scene)).is_true()
	runner.free()
	# give engine time to free the resources
	yield(await_idle_frame(), "completed")
	# verify runner and scene is freed
	assert_bool(is_instance_valid(runner)).is_false()
	assert_bool(is_instance_valid(scene)).is_false()

func test_runner_by_invalid_scene_instance() -> void:
	var scene = Reference.new()
	var runner := scene_runner(scene)
	assert_object(runner.scene()).is_null()

func test_runner_by_scene_instance() -> void:
	var scene = load("res://addons/gdUnit3/test/core/resources/scenes/simple_scene.tscn").instance()
	var runner := scene_runner(scene)
	assert_object(runner.scene()).is_instanceof(Node2D)
	
	# verify the scene is freed when the runner is freed
	runner.free()
	# give engine time to free the resources
	yield(await_idle_frame(), "completed")
	# verify runner and scene is freed
	assert_bool(is_instance_valid(runner)).is_false()
	assert_bool(is_instance_valid(scene)).is_false()

func test_mouse_drag_and_drop() -> void:
	var spy_scene = spy("res://addons/gdUnit3/test/core/resources/scenes/drag_and_drop/DragAndDropTestScene.tscn")
	var runner := scene_runner(spy_scene)
	OS.window_minimized = false
	
	var slot_left :TextureRect = $"/root/DragAndDropScene/left/TextureRect"
	var slot_right :TextureRect = $"/root/DragAndDropScene/right/TextureRect"
	
	var save_mouse_pos := get_tree().root.get_mouse_position()
	# set inital mouse pos over the left slot
	var mouse_pos := slot_left.rect_global_position + Vector2(10, 10)
	runner.set_mouse_pos(mouse_pos)
	yield(await_idle_frame(), "completed")
	var event := InputEventMouseMotion.new()
	event.position = mouse_pos
	event.global_position = save_mouse_pos
	verify(spy_scene, 1)._gui_input(event)
	
	runner.simulate_mouse_button_press(BUTTON_LEFT)
	yield(await_idle_frame(), "completed")
	assert_bool(Input.is_mouse_button_pressed(BUTTON_LEFT)).is_true()
	
	# start drag&drop to left pannel
	for i in 20:
		runner.simulate_mouse_move(mouse_pos + Vector2(i*.5*i, 0))
		yield(await_millis(40), "completed")
	
	runner.simulate_mouse_button_release(BUTTON_LEFT)
	yield(await_idle_frame(), "completed")
	assert_that(slot_right.texture).is_equal(slot_left.texture)


# we override the scene runner function for test purposes to hide push_error notifications
func scene_runner(scene, verbose := false) -> GdUnitSceneRunner:
	return auto_free(GdUnitSceneRunnerImpl.new(weakref(self), scene, verbose, true))

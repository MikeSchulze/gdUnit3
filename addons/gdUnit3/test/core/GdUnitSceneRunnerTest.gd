# GdUnit generated TestSuite
class_name GdUnitSceneRunnerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitSceneRunner.gd'

func test_get_property() -> void:
	var scene := scene_runner(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	
	assert_that(scene.get_property("_box1")).is_instanceof(ColorRect)
	assert_that(scene.get_property("_invalid")).is_equal("The property '_invalid' not exist on loaded scene.")

func test_invoke_method() -> void:
	var scene := scene_runner(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	
	assert_that(scene.invoke("add", 10, 12)).is_equal(22)
	assert_that(scene.invoke("sub", 10, 12)).is_equal("The method 'sub' not exist on loaded scene.")

func test_awaitForMilliseconds() -> void:
	var scene := scene_runner(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	
	var stopwatch = LocalTime.now()
	yield(scene.awaitOnMillis(1000), "completed")
	
	# verify we wait around 1000 ms (using 100ms offset because timing is not 100% accurate)
	assert_int(stopwatch.elapsed_since_ms()).is_between(900, 1100)

func test_simulate_frames(timeout = 1000) -> void:
	var scene := scene_runner(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	
	var box1 :ColorRect = scene.get_property("_box1")
	# initial is white
	assert_object(box1.color).is_equal(Color.white)
	
	# start color cycle by invoke the function 'start_color_cycle'
	scene.invoke("start_color_cycle")
	
	# we wait for 10 frames
	yield(scene.simulate_frames(10), "completed")
	# after 10 frame is still white
	assert_object(box1.color).is_equal(Color.white)
	
	# we wait 90 more frames
	yield(scene.simulate_frames(90), "completed")
	# after 100 frames the box one should be changed to red
	assert_object(box1.color).is_equal(Color.red)

func test_simulate_frames_withdelay(timeout = 1000) -> void:
	var scene := scene_runner(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	
	var box1 :ColorRect = scene.get_property("_box1")
	# initial is white
	assert_object(box1.color).is_equal(Color.white)
	
	# start color cycle by invoke the function 'start_color_cycle'
	scene.invoke("start_color_cycle")
	
	# we wait for 10 frames each with a 50ms delay
	yield(scene.simulate_frames(10, 50), "completed")
	# after 10 frame and in sum 500ms is should be changed to red
	assert_object(box1.color).is_equal(Color.red)

func test_run_scene_colorcycle(timeout=1700) -> void:
	var scene := scene_runner(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())

	var box1 :ColorRect = scene.get_property("_box1")
	# verify inital color
	assert_object(box1.color).is_equal(Color.white)
	
	# start color cycle by invoke the function 'start_color_cycle'
	scene.invoke("start_color_cycle")
	
	# await for each color cycle is emited
	yield(scene.awaitOnSignal("panel_color_change", box1, Color.red), "completed")
	assert_object(box1.color).is_equal(Color.red)
	yield(scene.awaitOnSignal("panel_color_change", box1, Color.blue), "completed")
	assert_object(box1.color).is_equal(Color.blue)
	yield(scene.awaitOnSignal("panel_color_change", box1, Color.green), "completed")
	assert_object(box1.color).is_equal(Color.green)

func test_simulate_key_pressed(timeout=2000) -> void:
	var scene := scene_runner(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	
	# inital no spell is fired
	assert_object(scene.find_node("Spell")).is_null()
	
	# fire spell be pressing enter key
	scene.simulate_key_pressed(KEY_ENTER)
	# wait until next frame
	yield(scene.awaitOnIdleFrame(), "completed")
	
	# verify a spell is created
	assert_object(scene.find_node("Spell")).is_not_null()
	
	# wait until spell is explode after around 1s
	var spell = scene.find_node("Spell")
	yield(awaitOnSignal(spell, "spell_explode", spell), "completed")
	
	# verify spell is removed when is explode
	assert_object(scene.find_node("Spell")).is_null()

# mock on a scene and spy on created spell
func test_simulate_key_pressed_in_combination_with_spy():
	var mocked_scene :Control = mock("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	assert_object(mocked_scene).is_not_null()
	# create a scene runner
	var runner := scene_runner(mocked_scene)
	
	# unsing spy to overwrite _create_spell() to spy on the spell
	var spell :Spell = auto_free(Spell.new())
	var spell_spy :Spell = spy(spell)
	do_return(spell_spy).on(mocked_scene)._create_spell()
	
	# simulate a key event to fire a spell
	runner.simulate_key_pressed(KEY_ENTER)
	verify(mocked_scene).create_spell()
	verify(mocked_scene).add_child(spell_spy)
	verify(spell_spy).connect("spell_explode", mocked_scene, "_destroy_spell")

func test_simulate_mouse_events():
	var spyed_scene = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spyed_scene)
	# enable for visualisize
	runner.maximize_view()
	
	# test button 1 interaction
	runner.set_mouse_pos(Vector2(60, 20))
	yield(get_tree().create_timer(1), "timeout")
	runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box1, Color.red)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box1, Color.gray)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box2, any_color())
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, any_color())
	
	# test button 2 interaction
	reset(spyed_scene)
	runner.set_mouse_pos(Vector2(160, 20))
	runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box1, any_color())
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box2, Color.red)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box2, Color.gray)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, any_color())
	
	# test button 3 interaction (is changed after 1s to gray)
	reset(spyed_scene)
	runner.set_mouse_pos(Vector2(260, 20))
	runner.simulate_mouse_button_pressed(BUTTON_LEFT)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box1, any_color())
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box2, any_color())
	# is changed to red
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box3, Color.red)
	# no gray
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, Color.gray)
	# after one second is changed to gray
	yield(get_tree().create_timer(1), "timeout")
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box3, Color.gray)

func test_wait_func_without_time_factor() -> void:
	var scene = auto_free(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	var runner := scene_runner(scene)
	
	yield(runner.wait_func(scene, "color_cycle").is_equal("black"), "completed")
	yield(runner.wait_func(scene, "color_cycle", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_equal("red"), "completed")\
		.has_failure_message("Expected: is equal 'red' but timed out after 500ms")

func test_wait_func_with_time_factor() -> void:
	var scene = auto_free(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	var runner := scene_runner(scene)
	# set max time factor to minimize waiting time on `runner.wait_func`
	runner.set_time_factor(10)
	yield(runner.wait_func(scene, "color_cycle").wait_until(200).is_equal("black"), "completed")
	yield(runner.wait_func(scene, "color_cycle", [], GdUnitAssert.EXPECT_FAIL).wait_until(100).is_equal("red"), "completed")\
		.has_failure_message("Expected: is equal 'red' but timed out after 100ms")

func test_wait_signal_without_time_factor() -> void:
	var scene = auto_free(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	var runner := scene_runner(scene)
	
	scene.start_color_cycle()
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.red], 600), "completed")
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.blue], 600), "completed")
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.green], 600), "completed")
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.khaki], 300, GdUnitAssert.EXPECT_FAIL), "completed")\
		.starts_with_failure_message("Expecting emit signal: 'panel_color_change(")

func test_wait_signal_with_time_factor() -> void:
	var scene = auto_free(load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn").instance())
	var runner := scene_runner(scene)
	# set max time factor to minimize waiting time on `runner.wait_func`
	runner.set_time_factor(10)
	
	scene.start_color_cycle()
	
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.red], 100), "completed")
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.blue], 100), "completed")
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.green], 100), "completed")
	yield(runner.wait_emit_signal(scene, "panel_color_change", [scene._box1, Color.khaki], 30, GdUnitAssert.EXPECT_FAIL), "completed")\
		.starts_with_failure_message("Expecting emit signal: 'panel_color_change(")

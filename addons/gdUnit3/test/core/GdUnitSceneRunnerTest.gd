# GdUnit generated TestSuite
class_name GdUnitSceneRunnerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitSceneRunner.gd'

func test_simulate_key_pressed_on_mock():
	var mocked_scene :Control = mock("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	assert_object(mocked_scene).is_not_null()
	assert_array(mocked_scene.get_children())\
		.extract("get_name")\
		.contains_exactly(["VBoxContainer"])
	
	# create a scene runner
	var runner := scene_runner(mocked_scene)
	
	# simulate a key event to fire the spell
	runner.simulate_key_pressed(KEY_ENTER)
	# verify the spell is created and added to the scene tree
	verify(mocked_scene).create_spell()
	verify(mocked_scene).add_child(any_class(Spell))
	assert_array(mocked_scene.get_children())\
		.extract("get_name")\
		.contains_exactly(["VBoxContainer", "Spell"])

func test_simulate_key_pressed_on_spy():
	var scene := load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var spyed_scene = spy(scene)
	assert_object(spyed_scene).is_not_null()
	assert_array(spyed_scene.get_children())\
		.extract("get_name")\
		.contains_exactly(["VBoxContainer"])
	
	# create a scene runner
	var runner := scene_runner(spyed_scene)
	
	# simulate a key event to fire the spell
	runner.simulate_key_pressed(KEY_ENTER)
	# verify the spell is created and added to the scene tree
	verify(spyed_scene).create_spell()
	verify(spyed_scene).add_child(any_class(Spell))
	assert_array(spyed_scene.get_children())\
		.extract("get_name")\
		.contains_exactly(["VBoxContainer", "Spell"])

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
	#var mocked_scene :Control = mock("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var scene := load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var spyed_scene = spy(scene)
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

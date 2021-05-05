# GdUnit generated TestSuite
class_name GdUnitSceneRunnerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/core/GdUnitSceneRunner.gd'


func test_simulate_key_pressed_on_mockw():
	var mocked_scene :Control = mock("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")

	
	# create a scene runner
	var runner := scene_runner(mocked_scene)

	# simulate a key event to fire the spell
	runner.simulate_key_pressed(KEY_ENTER)


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
	var runner := scene_runner(mocked_scene, true)
	
	# unsing spy to overwrite _create_spell() to spy on the spell
	var spell :Spell = auto_free(Spell.new())
	var spell_spy :Spell = spy(spell)
	do_return(spell_spy).on(mocked_scene)._create_spell()
	
	# simulate a key event to fire a spell
	runner.simulate_key_pressed(KEY_ENTER)
	verify(mocked_scene).create_spell()
	verify(mocked_scene).add_child(spell_spy)
	verify(spell_spy).connect("spell_explode", mocked_scene, "_destroy_spell")

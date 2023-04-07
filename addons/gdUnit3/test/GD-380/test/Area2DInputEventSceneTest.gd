# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
extends GdUnitTestSuite

# TestSuite generated from
const __source = "res://addons/gdUnit3/test/GD-380/scene/Demo.gd"



func test_mouse_entered_scale_up():
	var runner := scene_runner("res://addons/gdUnit3/test/GD-380/scene/Demo.tscn")
	# Pre-check mouse is not hovering over domino
	runner.set_mouse_pos(Vector2(500, 500))
	# needs to wait some frames the `_on_Area2D_mouse_entered` is emitted 
	yield(runner.simulate_frames(5, 10), "completed")
	

	# Get sprite scale before mouse entered
	# Get value only copy of node, rather than a reference
	var pre_sprite: Sprite = auto_free(runner.find_node("Sprite").duplicate())
	
	# Simulate mouse movement to center of domino
	runner.simulate_mouse_move(Vector2(5, 5))
	# needs to wait some frames the `_on_Area2D_mouse_entered` is emitted 
	yield(runner.simulate_frames(5, 10), "completed")

	# Verify that sprite scale changed
	var sprite: Sprite = runner.find_node("Sprite")
	assert_vector2(sprite.scale).is_not_equal(pre_sprite.scale)
	assert_vector2(sprite.scale).is_equal(runner.scene().hover_scale)

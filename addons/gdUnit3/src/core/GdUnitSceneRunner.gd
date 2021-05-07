# This class provides a runner for scense to simulate interactions like keyboard or mouse
class_name GdUnitSceneRunner
extends Node

var _scene_tree :SceneTree = null
var _scene :Node = null
var _scene_name :String
var _verbose :bool
var _simulate_start_time :LocalTime
var _current_mouse_pos :Vector2

func _init(scene :Node, verbose :bool):
	assert(scene != null, "Scene must be not null!")
	_scene_tree = Engine.get_main_loop()
	_scene_tree.root.add_child(self)
	add_child(scene)
	_verbose = verbose
	_scene = scene
	_scene_name = __extract_scene_name(scene)
	_simulate_start_time = LocalTime.now()
	__print("Start simulate %s" % _scene_name)
	# we have to remove the scene before tree exists, 
	# otherwise the scene is deleted by tree_exiting and causes into errors
	connect("tree_exited", self, "_tree_exiting")

func _tree_exiting():
	self.remove_child(_scene)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# we hide the scene/main window after runner is finished 
		OS.window_maximized = false
		OS.set_window_minimized(true)
		__print("End simulate %s, total time %s" % [_scene_name, _simulate_start_time.elapsed_since()])

# Simulates that a key has been pressed
# key_code : the key code e.g. 'KEY_ENTER'
# shift : false by default set to true if simmulate shift is press
# control : false by default set to true if simmulate control is press
func simulate_key_pressed(key_code :int, shift :bool = false, control := false) -> GdUnitSceneRunner:
	simulate_key_press(key_code, shift, control)
	simulate_key_release(key_code, shift, control)
	return self

# Simulates that a key is pressed
# key_code : the key code e.g. 'KEY_ENTER'
# shift : false by default set to true if simmulate shift is press
# control : false by default set to true if simmulate control is press
func simulate_key_press(key_code :int, shift :bool = false, control := false) -> GdUnitSceneRunner:
	__print_current_focus()
	var action = InputEventKey.new()
	action.pressed = true
	action.scancode = key_code
	action.shift = shift
	action.control = control
	__print("	process key event %s (%s) <- %s:%s" % [_scene, _scene_name, action.as_text(), "pressing" if action.is_pressed() else "released"])
	_scene_tree.input_event(action)
	return self

# Simulates that a key has been released
# key_code : the key code e.g. 'KEY_ENTER'
# shift : false by default set to true if simmulate shift is press
# control : false by default set to true if simmulate control is press
func simulate_key_release(key_code :int, shift :bool = false, control := false) -> GdUnitSceneRunner:
	__print_current_focus()
	var action = InputEventKey.new()
	action.pressed = false
	action.scancode = key_code
	action.shift = shift
	action.control = control
	__print("	process key event %s (%s) <- %s:%s" % [_scene, _scene_name, action.as_text(), "pressing" if action.is_pressed() else "released"])
	_scene_tree.input_event(action)
	return self

# Simulates a mouse moved to relative position by given speed
# relative: The mouse position relative to the previous position (position at the last frame).
# speed : The mouse speed in pixels per second.‚
func simulate_mouse_move(relative :Vector2, speed :Vector2 = Vector2.ONE) -> GdUnitSceneRunner:
	var action := InputEventMouseMotion.new()
	action.relative = relative
	action.speed = speed
	__print("	process mouse motion event %s (%s) <- %s" % [_scene, _scene_name, action.as_text()])
	_scene_tree.input_event(action)
	return self

# Simulates a mouse button pressed
# buttonIndex: The mouse button identifier, one of the ButtonList button or button wheel constants.
func simulate_mouse_button_pressed(buttonIndex :int) -> GdUnitSceneRunner:
	simulate_mouse_button_press(buttonIndex)
	simulate_mouse_button_release(buttonIndex)
	return self

# Simulates a mouse button press (holding)
# buttonIndex: The mouse button identifier, one of the ButtonList button or button wheel constants.
func simulate_mouse_button_press(buttonIndex :int) -> GdUnitSceneRunner:
	var action := InputEventMouseButton.new()
	action.button_index = buttonIndex
	action.button_mask = buttonIndex
	action.pressed = true
	action.position = _current_mouse_pos
	__print("	process mouse button event %s (%s) <- %s" % [_scene, _scene_name, action.as_text()])
	_scene_tree.input_event(action)
	return self

# Simulates a mouse button released
# buttonIndex: The mouse button identifier, one of the ButtonList button or button wheel constants.
func simulate_mouse_button_release(buttonIndex :int) -> GdUnitSceneRunner:
	var action := InputEventMouseButton.new()
	action.button_index = buttonIndex
	action.button_mask = 0
	action.pressed = false
	action.position = _current_mouse_pos
	__print("	process mouse button event %s (%s) <- %s" % [_scene, _scene_name, action.as_text()])
	_scene_tree.input_event(action)
	return self

# Sets the mouse cursor to given position relative to the viewport.
func set_mouse_pos(pos :Vector2) -> GdUnitSceneRunner:
	_scene.get_viewport().warp_mouse(pos)
	_current_mouse_pos = pos
	return self

# maximizes the window to bring the scene visible
func maximize_view() -> GdUnitSceneRunner:
	OS.window_maximized = true
	return self

func __extract_scene_name(node :Node) -> String:
	var scene_script :GDScript = node.get_script()
	if not scene_script:
		return node.get_name()
	if not node.get_name().begins_with("@"):
		return node.get_name()
	return scene_script.resource_name.get_basename()

func __print(message :String) -> void:
	if _verbose:
		prints(message)

func __print_current_focus() -> void:
	if not _verbose:
		return
	var focused_node = _scene.get_focus_owner()
	if focused_node:
		prints("	focus on %s" % focused_node)
	else:
		prints("	no focus set")

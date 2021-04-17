# This class provides a runner for scense to simulate interactions like keyboard or mouse
class_name GdUnitSceneRunner
extends Node

var _scene_tree :SceneTree = null
var _scene :Node = null
var _scene_name :String
var _is_spy := false
var _verbose :bool
var _simulate_start_time :LocalTime

static func is_spyed_scene(node :Node) -> bool:
	var scene_script :GDScript = node.get_script()
	if not scene_script:
		return false
	var properties := scene_script.get_script_property_list()
	for property in properties:
		if property.get("name") == "__instance_delegator":
			return true
	return false

func _init(scene :Node, verbose :bool):
	assert(scene != null, "Scene must be not null!")
	_scene_tree = Engine.get_main_loop()
	_scene_tree.root.add_child(self)
	if is_spyed_scene(scene):
		add_child(scene.__instance_delegator)
		_is_spy = true
	else:
		add_child(scene)
		_is_spy = false
	_verbose = verbose
	_scene = scene
	_scene_name = __extract_scene_name(scene)
	_simulate_start_time = LocalTime.now()
	__print("Start simulate %s" % _scene_name)
	# we have to remove the scene before tree exists, 
	# otherwise the scene is deleted by tree_exiting and causes into errors
	connect("tree_exited", self, "_tree_exiting")

func _tree_exiting():
	if _is_spy:
		self.remove_child(_scene.__instance_delegator)
	else:
		self.remove_child(_scene)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		__print("End simulate %s, total time %s" % [_scene_name, _simulate_start_time.elapsed_since()])

# Simulates that a key has been pressed
func simulate_key_pressed(key_code :int) -> GdUnitSceneRunner:
	simulate_key_press(key_code)
	simulate_key_release(key_code)
	return self

# Simulates that a key is pressed
func simulate_key_press(key_code :int) -> GdUnitSceneRunner:
	__print_current_focus()
	var action = InputEventKey.new()
	action.pressed = true
	action.scancode = key_code
	if _is_spy:
		process_key_event(_scene, action)
	else:
		__print("	process key event %s (%s) <- %s:%s" % [_scene, _scene_name, action.as_text(), "pressing" if action.is_pressed() else "released"])
		_scene_tree.input_event(action)
	return self

# Simulates that a key has been released
func simulate_key_release(key_code :int) -> GdUnitSceneRunner:
	__print_current_focus()
	var action = InputEventKey.new()
	action.pressed = false
	action.scancode = key_code
	if _is_spy:
		process_key_event(_scene, action)
	else:
		__print("	process key event %s (%s) <- %s:%s" % [_scene, _scene_name, action.as_text(), "pressing" if action.is_pressed() else "released"])
		_scene_tree.input_event(action)
	return self

func process_key_event(node :Node, event :InputEventKey, find_focus := true ) -> bool:
	var focused_node = node.get_focus_owner()
	if focused_node and find_focus:
		return process_key_event(focused_node, event, false)
		
	if node.has_method("_unhandled_input"):
		
		__print("	process key event %s (%s) <- %s:%s" % [node, _scene_name, event.as_text(), "pressing" if event.is_pressed() else "released"])
		#node._unhandled_input(event)
		# find script containing the input handler
		while node:
			if not node.get_script():
				node = node.get_parent()
				continue
			break
		__print("	Execute on %s:_unhandled_input" % node.get_script().resource_path)
		node._unhandled_input(event)
		return true

	for child in node.get_children():
		if process_key_event(child, event, find_focus):
			return true
	return false

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

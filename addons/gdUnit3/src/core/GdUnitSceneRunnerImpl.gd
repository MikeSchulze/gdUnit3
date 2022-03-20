# This class provides a runner for scense to simulate interactions like keyboard or mouse
class_name GdUnitSceneRunnerImpl
extends GdUnitSceneRunner

const NO_ARG = "<--null-->"

var _test_suite :WeakRef
var _scene_tree :SceneTree = null
var _current_scene :Node = null
var _verbose :bool
var _simulate_start_time :LocalTime
var _current_mouse_pos :Vector2
var _is_simulate_runnig := false
var _expected_signal_args :Array

# time factor settings
var _time_factor := 1.0
var _saved_time_scale :float
var _saved_iterations_per_second :float

func _init(test_suite :WeakRef, scene :Node, verbose :bool):
	_verbose = verbose
	_test_suite = test_suite
	assert(scene != null, "Scene must be not null!")
	_scene_tree = Engine.get_main_loop()
	_current_scene = scene
	_scene_tree.root.add_child(_current_scene)
	#add_child(_current_scene)
	_saved_iterations_per_second = ProjectSettings.get_setting("physics/common/physics_fps")
	set_time_factor(1)
	_simulate_start_time = LocalTime.now()

func _notification(what):
	#prints("_notification", GdObjects.notification_as_string(what), self, _current_scene, _scene_tree)
	if what == NOTIFICATION_PREDELETE:
		__deactivate_time_factor()
		if is_instance_valid(_current_scene):
			_scene_tree.root.remove_child(_current_scene)
		
		_scene_tree = null
		_current_scene = null
		_test_suite = null
		# reset time factor to normal
		# we hide the scene/main window after runner is finished 
		OS.window_maximized = false
		OS.set_window_minimized(true)

# resets the scene to inital state
# needs to more investigate how to reset a loaded scene fully, calling _ready is not enough
#func reset() -> Node:
#	__print("reset scene")
#	__reset(_current_scene)
#	return _current_scene

#func __reset(node: Node):
#	for child in node.get_children():
#		__reset(child)
#	if node.has_method("_ready"):
#		node._ready()

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
	__print("	process key event %s (%s) <- %s:%s" % [_current_scene, _scene_name(), action.as_text(), "pressing" if action.is_pressed() else "released"])
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
	__print("	process key event %s (%s) <- %s:%s" % [_current_scene, _scene_name(), action.as_text(), "pressing" if action.is_pressed() else "released"])
	_scene_tree.input_event(action)
	return self

# Simulates a mouse moved to relative position by given speed
# relative: The mouse position relative to the previous position (position at the last frame).
# speed : The mouse speed in pixels per second.‚
func simulate_mouse_move(relative :Vector2, speed :Vector2 = Vector2.ONE) -> GdUnitSceneRunner:
	var action := InputEventMouseMotion.new()
	action.relative = relative
	action.speed = speed
	__print("	process mouse motion event %s (%s) <- %s" % [_current_scene, _scene_name(), action.as_text()])
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
	__print("	process mouse button event %s (%s) <- %s" % [_current_scene, _scene_name(), action.as_text()])
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
	__print("	process mouse button event %s (%s) <- %s" % [_current_scene, _scene_name(), action.as_text()])
	_scene_tree.input_event(action)
	return self

# Sets how fast or slow the scene simulation is processed (clock ticks versus the real).
# It defaults to 1.0. A value of 2.0 means the game moves twice as fast as real life,
# whilst a value of 0.5 means the game moves at half the regular speed.
func set_time_factor(time_factor := 1.0) -> GdUnitSceneRunner:
	_time_factor = min(9.0, time_factor)
	__print("set time factor: %f" % _time_factor)
	__print("set physics iterations_per_second: %d" % (_saved_iterations_per_second*_time_factor))
	return self

# Simulates scene processing for a certain number of frames by given delta peer frame by ignoring the time factor
# frames: amount of frames to process
# delta_peer_frame: the time delta between a frame in ms
func simulate(frames: int, delta_peer_frame :float) -> GdUnitSceneRunner:
	push_warning("DEPRECATED!: 'simulate(<frames>, <delta_peer_frame>)' is deprecated. Use  'simulate_frames(<frames>, <delta_milli>) insted.'")
	return simulate_frames(frames, delta_peer_frame * 1000)

# Simulates scene processing for a certain number of frames
# frames: amount of frames to process
# delta_milli: the time delta between a frame in milliseconds
func simulate_frames(frames: int, delta_milli :int = -1) -> GdUnitSceneRunner:
	if delta_milli == -1:
		return __simulate_frames_on_idle(frames);
	
	__deactivate_time_factor()
	for frame in frames:
		_is_simulate_runnig = true
		yield(doAwaitOnMillis(delta_milli), "completed")
	_is_simulate_runnig = false
	return self

# Simulates scene processing for a certain number of frames
# frames: amount of frames to process
func __simulate_frames_on_idle(frames: int) -> GdUnitSceneRunner:
	var time_shift_frames := max(1, frames / _time_factor)
	#prints("time_shift_frames:", time_shift_frames)
	__activate_time_factor()
	for frame in time_shift_frames:
		_is_simulate_runnig = true
		yield(doAwaitOnIdleFrame(), "completed")
	__deactivate_time_factor()
	_is_simulate_runnig = false
	return self

# Simulates scene processing until the given signal is emitted by the scene
# signal_name: the signal to stop the simulation
# arg..: optional signal arguments to be matched for stop
func simulate_until_signal(signal_name :String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> GdUnitSceneRunner:
	return simulate_until_object_signal(_current_scene, signal_name, arg0, arg1, arg2, arg3, arg4, arg5)

# Simulates scene processing until the given signal is emitted by the given object
# source: the object that should emit the signal
# signal_name: the signal to stop the simulation
# arg..: optional signal arguments to be matched for stop	
func simulate_until_object_signal(source :Object, signal_name :String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> GdUnitSceneRunner:
	source.connect(signal_name, self, "__interupt_simulate")
	_expected_signal_args = [arg0, arg1, arg2, arg3, arg4, arg5]
	_is_simulate_runnig = true
	__activate_time_factor()
	while _is_simulate_runnig:
		yield(_scene_tree, "idle_frame")
	__deactivate_time_factor()
	return self

# Waits for function return value until specified timeout or fails
# instance: the object instance where implements the function
# args : optional function arguments
func wait_func(instance :Object, func_name :String, args := [], expeced := GdUnitAssert.EXPECT_SUCCESS) -> GdUnitFuncAssert:
	__activate_time_factor()
	return GdUnitFuncAssertImpl.new(_test_suite, instance, func_name, args, expeced)

# Waits for given signal until specified timeout or fails
# instance: the object where emittes the signal
# signal_name: signal name
# args: args send be the signal
# timeout: the timeout in ms, default is set to 2000ms
func wait_emit_signal(instance :Object, signal_name :String, args := [], timeout := 2000, expeced := GdUnitAssert.EXPECT_SUCCESS) -> GDScriptFunctionState:
	return doAwaitOnSignal(signal_name, _get_arg(0, args), _get_arg(1, args), _get_arg(2, args), _get_arg(3, args), _get_arg(4, args), _get_arg(5, args))

func _get_arg(index :int, args: Array):
	if index < args.size():
		return args[index]
	return NO_ARG

func __wait_signal_completed(arg):
	_is_simulate_runnig = false

func __interupt_simulate(arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null):
	var current_signal_args = [arg0, arg1, arg2, arg3, arg4, arg5]
	# if signal has expected args we have to compare with received ones and only if matches we stop
	for i in _expected_signal_args.size():
		var expected_arg = _expected_signal_args[i]
		var signal_arg = current_signal_args[i]
		if expected_arg != null and expected_arg != signal_arg:
			return
	_is_simulate_runnig = false

# Sets the mouse cursor to given position relative to the viewport.
func set_mouse_pos(pos :Vector2) -> GdUnitSceneRunner:
	_current_scene.get_viewport().warp_mouse(pos)
	_current_mouse_pos = pos
	return self

# maximizes the window to bring the scene visible
func maximize_view() -> GdUnitSceneRunner:
	OS.set_window_maximized(true)
	OS.center_window()
	OS.move_window_to_foreground()
	return self

func _scene_name() -> String:
	var scene_script :GDScript = _current_scene.get_script()
	if not scene_script:
		return _current_scene.get_name()
	if not _current_scene.get_name().begins_with("@"):
		return _current_scene.get_name()
	return scene_script.resource_name.get_basename()

func __activate_time_factor() -> void:
	Engine.set_time_scale(_time_factor)
	Engine.set_iterations_per_second(_saved_iterations_per_second * _time_factor)

func __deactivate_time_factor() -> void:
	Engine.set_time_scale(1)
	Engine.set_iterations_per_second(_saved_iterations_per_second)

func doAwaitOnIdleFrame() -> GDScriptFunctionState:
	return yield(_scene_tree, "idle_frame")

func doAwaitOnMillis(timeMillis :int) -> GDScriptFunctionState:
	return yield(_scene_tree.create_timer( timeMillis * 0.001), "timeout")

func doAwaitOnSignal(signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG) -> GDScriptFunctionState:
	__activate_time_factor()
	var fs = yield(GdUnitAwaiter.doAwaitOnSignal(_current_scene, signal_name, arg0,arg1,arg2,arg3,arg4,arg5), "completed")
	if fs is GDScriptFunctionState:
		return yield(fs, "completed")
	__deactivate_time_factor()
	return fs

func get_property(name :String):
	var property = _current_scene.get(name)
	if property != null:
		return property
	return  "The property '%s' not exist on loaded scene." % name

func invoke(name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	var args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	if _current_scene.has_method(name):
		return _current_scene.callv(name, args)
	return "The method '%s' not exist on loaded scene." % name

func find_node(name :String, recursive :bool = true, owned :bool = false) -> Node:
	return _current_scene.find_node(name, recursive, owned)

func __print(message :String) -> void:
	if _verbose:
		prints(message)

func __print_current_focus() -> void:
	if not _verbose:
		return
	var focused_node = _current_scene.get_focus_owner()
	if focused_node:
		prints("	focus on %s" % focused_node)
	else:
		prints("	no focus set")

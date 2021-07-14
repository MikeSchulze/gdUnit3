class_name RoomWithDoor
extends Spatial


signal door_closed(door_id)
signal door_opened(door_id)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup_input_mappings()

func setup_input_mappings():
	add_input_key_action("player_room3ddemo_input_up", KEY_W)
	add_input_key_action("player_room3ddemo_input_down", KEY_S)
	add_input_key_action("player_room3ddemo_input_left", KEY_A)
	add_input_key_action("player_room3ddemo_input_right", KEY_D)
	add_input_key_action("player_room3ddemo_input_exit", KEY_ESCAPE)
	add_input_mouse_action("player_room3ddemo_input_fire", BUTTON_LEFT)

func add_input_key_action(action_name :String, key_scancode :int):
	var input_event := InputEventKey.new()
	input_event.set_scancode(key_scancode)
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		InputMap.action_add_event(action_name, input_event)

func add_input_mouse_action(action_name :String, button_index :int):
	var input_event := InputEventMouseButton.new()
	input_event.button_index = button_index
	input_event.button_mask = 0
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		InputMap.action_add_event(action_name, input_event)

func _process(_delta):
	if Input.is_action_just_pressed("player_room3ddemo_input_exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()

func _on_door_door_closed(door_id):
	emit_signal("door_closed", door_id)

func _on_door_door_opend(door_id):
	emit_signal("door_opened", door_id)

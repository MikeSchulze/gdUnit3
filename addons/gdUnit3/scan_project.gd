#!/usr/bin/env -S godot -s
tool
extends SceneTree

enum {
	INIT,
	SCAN,
	QUIT
}

var _counter = 0
var WAIT_TIME_IN_MS = 1.000
var _state = INIT

func _init():
	set_auto_accept_quit(true)
	fix_cache_bug()
	print("Scan for project changes ...")
	_state = SCAN

func _idle(delta):
	yield(root.get_tree(), "idle_frame")
	if _state != SCAN:
		return
	_counter += delta
	if _counter >= WAIT_TIME_IN_MS:
		prints("Scan for project changes done", root.get_tree())
		_state = QUIT
		exit()

# see https://github.com/godotengine/godot/issues/62820 for more details
func fix_cache_bug():
	for node in root.get_children():
		if node.name.begins_with("EditorNode"):
			for child in node.get_children():
				if child is EditorResourcePreview:
					var prewview := child as EditorResourcePreview
					prewview.check_for_invalidation("res://")
	yield(root.get_tree(), "idle_frame")

func exit():
	prints("Exit")
	key_pressed(KEY_Q, true)
	key_pressed(KEY_ENTER)

func key_pressed(key_code :int, command := false):
	key_press(key_code, command)
	key_release(key_code, command)

func key_press(key_code :int, command := false):
	var action = InputEventKey.new()
	action.pressed = true
	action.scancode = key_code
	action.command = command
	input_event(action)

func key_release(key_code :int,command := false):
	var action = InputEventKey.new()
	action.pressed = false
	action.scancode = key_code
	action.command = command
	input_event(action)

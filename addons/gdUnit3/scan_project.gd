#!/usr/bin/env -S godot -s
tool
extends SceneTree

enum {
	INIT,
	SCAN,
	QUIT
}

var _counter = 0
var WAIT_TIME_IN_MS = 5.000
var _state = INIT

func _init():
	print("Scan for project changes ...")
	prints(OS.get_time())
	_state = SCAN

func _idle(delta):
	if _state != SCAN:
		return
	_counter += delta
	prints("scanning", _counter, OS.get_time(), OS.get_process_id())
	yield(root.get_tree(), "idle_frame")
	if _counter >= WAIT_TIME_IN_MS:
		_state = QUIT
		prints("Scan for project changes done")
		yield(root.get_tree(), "idle_frame")
		finish()
		#prints("kill", OS.kill(OS.get_process_id()))
		yield(root.get_tree(), "idle_frame")

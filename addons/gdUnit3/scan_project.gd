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
	disable_gdUnit()
	print("Scan for project changes ...")
	_state = SCAN

func _idle(delta):
	if _state != SCAN:
		return
	_counter += delta
	#prints("scanning", _counter, OS.get_time(), OS.get_process_id())
	yield(root.get_tree(), "idle_frame")
	if _counter >= WAIT_TIME_IN_MS:
		prints("Scan for project changes done")
		_state = QUIT
		#finish()
		rescan()
		#Engine.get_main_loop().finish()
		OS.kill(OS.get_process_id())


func rescan(update_scripts :bool = false) -> void:
	yield(root.get_tree(), "idle_frame")
	var plugin := EditorPlugin.new()
	var fs := plugin.get_editor_interface().get_resource_filesystem()
	fs.scan_sources()
	while fs.is_scanning():
		yield(root.get_tree().create_timer(1), "timeout")
	if update_scripts:
		plugin.get_editor_interface().get_resource_filesystem().update_script_classes()
	plugin.free()


static func disable_gdUnit() -> void:
	prints("disable_gdUnit")
	var plugin := EditorPlugin.new()
	plugin.get_editor_interface().set_plugin_enabled("gdUnit3", false)
	plugin.free()

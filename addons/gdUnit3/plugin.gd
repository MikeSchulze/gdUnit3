tool
extends EditorPlugin

var _gd_inspector :Node
var _server_node
var _gd_console :Node
var _update_tool :Node
var _singleton :GdUnitSingleton = GdUnitSingleton.new()

func _enter_tree():
	Engine.set_meta("GdUnitEditorPlugin", self)
	GdUnitSettings.setup()
	# show possible update notification when is enabled
	if GdUnitSettings.is_update_notification_enabled():
		_update_tool = load("res://addons/gdUnit3/src/update/GdUnitUpdate.tscn").instance()
		get_parent().add_child(_update_tool)
	
	# install SignalHandler singleton
	GdUnitSingleton.add_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
	# install the GdUnit inspector
	_gd_inspector = load("res://addons/gdUnit3/src/ui/GdUnitInspector.tscn").instance()
	_gd_inspector.set_editor_interface(get_editor_interface())
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _gd_inspector)
	# install the GdUnit Console
	_gd_console = load("res://addons/gdUnit3/src/ui/GdUnitConsole.tscn").instance()
	add_control_to_bottom_panel(_gd_console, "gdUnitConsole")
	# needs to wait before we can add a child to the root
	yield(get_tree(), "idle_frame")
	_server_node = load("res://addons/gdUnit3/src/network/GdUnitServer.tscn").instance()
	add_child(_server_node)
	var err := _gd_inspector.connect("gdunit_runner_stop", _server_node, "_on_gdunit_runner_stop")
	if err != OK:
		prints("ERROR", GdUnitTools.error_as_string(err))
	prints("Loading GdUnit3 Plugin success")

func _exit_tree():
	remove_control_from_docks(_gd_inspector)
	remove_control_from_bottom_panel(_gd_console)
	remove_child(_server_node)
	
	_gd_inspector.free()
	_gd_console.free()
	_server_node.free()
	# Delete and release the update tool only when it is not in use, otherwise it will interrupt the execution of the update
	if _update_tool and not _update_tool.is_update_in_progress():
		get_parent().call_deferred("remove_child", _update_tool)
		yield(get_tree(), "idle_frame")
		_update_tool.free()
	GdUnitSingleton.remove_singleton(SignalHandler.SINGLETON_NAME)
	Engine.remove_meta("GdUnitEditorPlugin")
	prints("Unload GdUnit3 Plugin success")

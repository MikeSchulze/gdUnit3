tool
extends EditorPlugin

var _gd_inspector :Node
var _server_node
var _gd_console:Node
var _singleton :GdUnitSingleton = GdUnitSingleton.new()

func _enter_tree():
	Engine.set_meta("GdUnitEditorPlugin", self)
	GdUnitSettings.setup()
	
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
	get_tree().root.add_child(_server_node)
	var err := _gd_inspector.connect("gdunit_runner_stop", _server_node, "_on_gdunit_runner_stop")
	if err != OK:
		prints("ERROR", GdUnitTools.error_as_string(err))
	prints("Loading GdUnit3 Plugin success")

func _exit_tree():
	remove_control_from_docks(_gd_inspector)
	remove_control_from_bottom_panel(_gd_console)
	get_tree().root.remove_child(_server_node)
	
	_server_node.queue_free()
	_gd_inspector.queue_free()
	_gd_console.queue_free()
	GdUnitSingleton.remove_singleton(SignalHandler.SINGLETON_NAME)
	prints("Unload GdUnit3 Plugin success")

#func make_visible(visible: bool):
#	if _gd_inspector:
#		_gd_inspector.set_visible(true)

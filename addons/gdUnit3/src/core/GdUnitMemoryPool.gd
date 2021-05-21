class_name GdUnitMemoryPool 
extends Node

const META_PARAM := "MEMORY_POOL"

enum  {
	SUITE_SETUP,
	TEST_SETUP,
	TEST_EXECUTE,
	PUSH_ERROR,
}

var _monitors := {
	SUITE_SETUP : GdUnitMemMonitor.new("SUITE_SETUP"),
	TEST_SETUP : GdUnitMemMonitor.new("TEST_SETUP"),
	TEST_EXECUTE : GdUnitMemMonitor.new("TEST_EXECUTE"),
	PUSH_ERROR : PushErrorMonitor.new(),
}

var _monitored_pool_order := Array()
var _current :int

func _init():
	set_name("GdUnitMemoryPool-%d" % get_instance_id())

func set_pool(obj :Object, pool_id :int, reset_monitor: bool = false) -> void:
	_current = pool_id
	obj.set_meta(META_PARAM, pool_id)
	var monitor := get_monitor(_current)
	if reset_monitor:
		monitor.reset()
	monitor.start()

func monitor_stop() -> void:
	var monitor := get_monitor(_current)
	monitor.stop()

func free_pool() -> void:
	GdUnitTools.run_auto_free(_current)
	
func get_monitor(pool_id :int) -> GdUnitMemMonitor:
	return _monitors.get(pool_id)

func orphan_nodes() -> int:
	return _monitors.get(_current).orphan_nodes()

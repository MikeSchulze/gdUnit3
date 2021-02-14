class_name GdUnitMemMonitor
extends GdUnitMonitor

var _orphan_nodes_start :int
var _orphan_nodes_end :int

func _init(name :String = "").("MemMonitor:" + name):
	_orphan_nodes_start = 0
	_orphan_nodes_end = 0

func start():
	_orphan_nodes_start = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func stop():
	_orphan_nodes_end = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func orphan_nodes() -> int:
	return _orphan_nodes_end - _orphan_nodes_start

func subtract(count :int):
	_orphan_nodes_end -= count

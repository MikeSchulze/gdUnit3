class_name PushErrorMonitor
extends GdUnitMonitor

var _runner
var _first_error := Dictionary()
var _last_error := Dictionary()

func _init().("PushErrorMonitor"):
	if not Engine.has_meta("GdUnitRunner"):
		#push_error("Can't find a GdUnit runner instance")
		_runner = null
		return
	_runner = Engine.get_meta("GdUnitRunner")

func start():
	if not _runner:
		return
	yield(Engine.get_main_loop().create_timer(0.100), "timeout")
	_first_error = Dictionary()
	_last_error = Dictionary()
	var result = yield(_runner.get_last_push_error(), "completed")
	if result.is_success():
		_first_error = result.value()
	else:
		prints(result)

func stop():
	if not _runner:
		return
	# give the engine time to complete the last push_error notification 
	yield(Engine.get_main_loop().create_timer(0.100), "timeout")
	var result = yield(_runner.get_last_push_error(), "completed")
	if result.is_success():
		_last_error = result.value()

func list_errors() -> Array:
	if not _runner:
		return
	yield(Engine.get_main_loop(), "idle_frame")
	var from = _first_error.get("item_id", -1)
	var to = _last_error.get("item_id", -1)
	
	if from == to:
		return Array()
	var result =  yield(_runner.get_list_push_error(from, to), "completed")
	if result.is_success():
		return result.value()
	return Array()


#func _notification(what):
#	prints("error_mon", self, GdObjects.notification_as_string(what))

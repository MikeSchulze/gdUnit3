tool
extends Node

onready var _server :Network = $Network
onready var _error_handler :GdUnitPushErrorHandler = $ErrorHandler
var _signal_handler :SignalHandler

# holds tasks to execute by key = task_name and value = GdUnitTask
var _tasks := Dictionary() 

func _ready():
	_signal_handler = GdUnitSingleton.get_or_create_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
	_server.start_server()
	_server.connect("client_connected", self, "_on_client_connected")
	_server.connect("client_disconnected", self, "_on_client_disconnected")
	_server.connect("server_message", self, "_on_server_message")
	_signal_handler.send_message("GdUnitServer started")
	
	register_tasks(_error_handler.get_tasks())

remote func sync_rpc_id_request(request :Dictionary):
	#prints("		->exec", request.get(GdUnitTask.TASK_NAME))
	var client_id := get_tree().get_rpc_sender_id()
	var result := execute_task(request.get(GdUnitTask.TASK_NAME), request.get(GdUnitTask.TASK_ARGS))
	#prints("		<-send response:", request.get(GdUnitTask.TASK_NAME), typeof(result.value()))
	rpc_id(client_id, "sync_rpc_id_request_response", Result.serialize(result))

remote func async_rpc_id_request(request :Dictionary):
	#prints("		->exec", request.get(GdUnitTask.TASK_NAME))
	var client_id := get_tree().get_rpc_sender_id()
	execute_task(request.get(GdUnitTask.TASK_NAME), request.get(GdUnitTask.TASK_ARGS))

func register_tasks(tasks :Array) -> void:
	for task in tasks:
		register_task(task as GdUnitTask)

func register_task(task :GdUnitTask) -> void:
	if _tasks.has(task.name()):
		push_error("An task with name '%s' is already registered." % task.name())
		return
	_tasks[task.name()] = task

func execute_task(task_name :String, task_args :Array) -> Result:
	if not _tasks.has(task_name):
		push_error("Invalid task: can't find a registerd task by name '%s'" % task_name)
		return null
	var task :GdUnitTask = _tasks.get(task_name)
	return task.execute(task_args)


func _on_client_connected(client_id :int) -> void:
	_signal_handler.client_connected(client_id)

func _on_client_disconnected(client_id :int) -> void:
	_signal_handler.client_disconnected(client_id)

func _on_gdunit_runner_stop(client_id :int):
	_server.disconnect_client(client_id)

func _on_server_message(message :String):
	_signal_handler.send_message(message)

remote func receive_message(message :String):
	_signal_handler.send_message(message)

remote func receive_test_suite(obj :Dictionary):
	var test_suite := GdSerde.deserialize_test_suite(obj)
	_signal_handler.send_add_test_suite(test_suite)

remote func receive_event(data :Dictionary):
	var event:GdUnitEvent = GdUnitEvent.new().deserialize(data)
	_signal_handler.send_event(event)

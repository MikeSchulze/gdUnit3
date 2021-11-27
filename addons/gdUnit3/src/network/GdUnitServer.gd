tool
extends Node

onready var _server :GdUnitTcpServer = $TcpServer
#onready var _error_handler :GdUnitPushErrorHandler = $ErrorHandler

var _signal_handler :SignalHandler


# holds tasks to execute by key = task_name and value = GdUnitTask
var _tasks := Dictionary() 

func _ready():
	_signal_handler = GdUnitSingleton.get_or_create_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
	var result := _server.start()
	if result.is_error():
		push_error(result.error_message())
		return
	var server_port :int = result.value()
	Engine.set_meta("gdunit_server_port", server_port)
	
	_server.connect("client_connected", self, "_on_client_connected")
	_server.connect("client_disconnected", self, "_on_client_disconnected")
	_server.connect("rpc_data", self, "_receive_rpc_data")
	
	#register_tasks(_error_handler.get_tasks())

#remote func sync_rpc_id_request(request :Dictionary):
#	#prints("		->exec", request.get(GdUnitTask.TASK_NAME))
#	var client_id := get_tree().get_rpc_sender_id()
#	var result := execute_task(request.get(GdUnitTask.TASK_NAME), request.get(GdUnitTask.TASK_ARGS))
#	#prints("		<-send response:", request.get(GdUnitTask.TASK_NAME), typeof(result.value()))
#	rpc_id(client_id, "sync_rpc_id_request_response", Result.serialize(result))

#remote func async_rpc_id_request(request :Dictionary):
#	#prints("		->exec", request.get(GdUnitTask.TASK_NAME))
#	var client_id := get_tree().get_rpc_sender_id()
#	execute_task(request.get(GdUnitTask.TASK_NAME), request.get(GdUnitTask.TASK_ARGS))

#func register_tasks(tasks :Array) -> void:
#	for task in tasks:
#		register_task(task as GdUnitTask)

#func register_task(task :GdUnitTask) -> void:
#	if _tasks.has(task.name()):
#		push_error("An task with name '%s' is already registered." % task.name())
#		return
#	_tasks[task.name()] = task

#func execute_task(task_name :String, task_args :Array) -> Result:
#	if not _tasks.has(task_name):
#		push_error("Invalid task: can't find a registerd task by name '%s'" % task_name)
#		return null
#	var task :GdUnitTask = _tasks.get(task_name)
#	return task.execute(task_args)


func _on_client_connected(client_id :int) -> void:
	_signal_handler.client_connected(client_id)

func _on_client_disconnected(client_id :int) -> void:
	_signal_handler.client_disconnected(client_id)

func _on_gdunit_runner_stop(client_id :int):
	if _server:
		_server.disconnect_client(client_id)

func _receive_rpc_data(rpc :RPC) -> void:
	if rpc is RPCMessage:
		_signal_handler.send_message(rpc.message())
		return
	if rpc is RPCGdUnitEvent:
		_signal_handler.send_event(rpc.event())
		return
	if rpc is RPCGdUnitTestSuite:
		_signal_handler.send_add_test_suite(rpc.dto())

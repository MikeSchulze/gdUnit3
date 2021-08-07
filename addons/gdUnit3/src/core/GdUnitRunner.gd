extends Node

const GDUNIT_RUNNER = "GdUnitRunner"

signal sync_rpc_id_result_received

onready var _client :GdUnitTcpClient = $GdUnitTcpClient
onready var _executor :GdUnitExecutor = $GdUnitExecutor


enum {
	INIT,
	RUN,
	STOP,
	EXIT
}
var _config := GdUnitRunnerConfig.new()
var _test_suites_to_process :Array
var _state = INIT
var _signal_handler :SignalHandler

# holds the received sync rpc result
var _result :Result

func _init():
	# minimize scene window on debug mode
	if OS.get_cmdline_args().size() == 1:
		OS.set_window_title("GdUnit3 Runner (Debug)")
		OS.set_window_minimized(true)
	_signal_handler = GdUnitSingleton.get_or_create_singleton(SignalHandler.SINGLETON_NAME, "res://addons/gdUnit3/src/core/event/SignalHandler.gd")
	# store current runner instance to engine meta data to can be access in as a singleton
	Engine.set_meta(GDUNIT_RUNNER, self)

func _ready():
	_config.load()
	var result := _client.start("127.0.0.1", _config.server_port())
	if result.is_error():
		push_error(result.error_message())
		return
	_test_suites_to_process = load_test_suits()
	_state = INIT

func _notification(what):
	#prints("GdUnitRunner", self, GdObjects.notification_as_string(what))
	if what == NOTIFICATION_PREDELETE:
		Engine.remove_meta(GDUNIT_RUNNER)

func _process(delta):
	match _state:
		INIT:
			# wait until client is connected to the GdUnitServer
			if _client.is_client_connected():
				gdUnitInit()
				_state = RUN
		RUN:
			# all test suites executed
			if _test_suites_to_process.empty():
				_state = STOP
			else:
				# process next test suite
				var test_suite := _test_suites_to_process.pop_front() as GdUnitTestSuite
				var fs = _executor.execute(test_suite)
				# is yielded than wait for completed
				if GdUnitTools.is_yielded(fs):
					set_process(false)
					yield(fs, "completed")
					set_process(true)
		STOP:
			_state = EXIT
			# give the engine small amount time to finish the rpc
			yield(get_tree().create_timer(0.1), "timeout")
			yield(get_tree(), "idle_frame")
			_on_Executor_send_event(GdUnitStop.new())

func load_test_suits() -> Array:
	var result := _config.load()
	if result.is_error():
		push_error(result.error_message())
		_state = EXIT
		return []
	var to_execute := _config.to_execute()
	if to_execute.empty():
		prints("No tests selected to execute!")
		_state = EXIT
		return []
	# scan for the requested test suites
	var test_suites := Array()
	var _scanner := _TestSuiteScanner.new()
	for resource_path in to_execute.keys():
		var selected_tests :Array = to_execute.get(resource_path)
		var scaned_suites := _scanner.scan(resource_path)
		_filter_test_case(scaned_suites, selected_tests)
		test_suites += scaned_suites
	_scanner.free()
	return test_suites

func gdUnitInit() -> void:
	#enable_manuall_polling()
	send_message("Scaned %d test suites" % _test_suites_to_process.size())
	var total_count = _collect_test_case_count(_test_suites_to_process)
	_on_Executor_send_event(GdUnitInit.new(_test_suites_to_process.size(), total_count))
	for t in _test_suites_to_process:
		var test_suite := t as GdUnitTestSuite
		send_test_suite(test_suite)

func _filter_test_case(test_suites :Array, test_case_names :Array) -> void:
	if test_case_names.empty():
		return
	for test_suite in test_suites:
		for test_case in test_suite.get_children():
			if not test_case_names.has(test_case.get_name()):
				test_suite.remove_child(test_case)
				test_case.free()

func _collect_test_case_count(testSuites :Array) -> int:
	var total :int = 0
	for test_suite in testSuites:
		total += (test_suite as Node).get_child_count()
	return total

# RPC send functions
func send_message(message :String):
	_client.rpc_send(RPCMessage.of(message))

func send_test_suite(test_suite :GdUnitTestSuite):
	_client.rpc_send(RPCGdUnitTestSuite.of(test_suite))

func _on_Executor_send_event(event :GdUnitEvent):
	_client.rpc_send(RPCGdUnitEvent.of(event))

#func get_last_push_error() -> Result:
#	return yield(sync_rpc_id(1, "GdUnitPushErrorHandler:get_last_error"), "completed")

#func get_list_push_error(from_id :int, to_id :int) -> Result:
#	return yield(sync_rpc_id(1, "GdUnitPushErrorHandler:list_errors", [from_id, to_id]), "completed")

#func clear_push_errors() -> Result:
#	return async_rpc_id(1, "GdUnitPushErrorHandler:clear_error_list")


# sends an syncronized rpc call to <peer_id> and waits until a response is received
# 
# peer_id: the id to send 1 for server and >1 for clients
# task_name: the name of remote task to execute
# task_args: optional task arugments as Dictionary key:value
#
# returns a Result with state SUCCESS or ERROR
sync func sync_rpc_id(peer_id :int, task_name :String, task_args :Array = Array()) -> Result:
	rpc_id(peer_id, "sync_rpc_id_request",  { GdUnitTask.TASK_NAME: task_name, GdUnitTask.TASK_ARGS: task_args})
	# wait until the responce is received
	yield(self, "sync_rpc_id_result_received")
	return _result

# sends an asyncronized rpc call to <peer_id> and returns without status
# 
# peer_id: the id to send 1 for server and >1 for clients
# task_name: the name of remote task to execute
# task_args: optional task arugments as Dictionary key:value
#
sync func async_rpc_id(peer_id :int, task_name :String, task_args :Array = Array()) -> void:
	rpc_id(peer_id, "async_rpc_id_request",  { GdUnitTask.TASK_NAME: task_name, GdUnitTask.TASK_ARGS: task_args})

# responce the result form 'sync_rpc_id'
remote func sync_rpc_id_request_response(value :Dictionary):
	_result = Result.deserialize(value)
	# emit signal result successfully received
	emit_signal("sync_rpc_id_result_received")



# !!! Use only in a debug scenario !!!
# If the main thread is blocked for a longer time the
# network connection is closed by a timeout.
# We have to poll regularly to send a sign of life to the server.
#
# debugging is broken when using threads!!!!
# https://github.com/godotengine/godot/issues/42901
func enable_manuall_polling() -> void:
	prints("enable_manuall_polling", self, get_tree())
	var poller = PollTread.new()
	add_child(poller)
	poller.start(get_tree())


class PollTread extends Node:
	var _poll_thread:Thread = Thread.new()
	
	func start(scene_tree :SceneTree):
		scene_tree.set_multiplayer_poll_enabled(false)
		var error = _poll_thread.start(self, "_poll", scene_tree.multiplayer, Thread.PRIORITY_LOW)
		if error != OK:
			push_error("faild to run network poll thread")
			_poll_thread = null	
	
	func _poll(multiplayer :MultiplayerAPI) -> void:
		while true:
			#yield(get_tree().create_timer(0.1), "timeout")
			
			prints("poll network", self, multiplayer, multiplayer.network_peer.get_connection_status())
			multiplayer.poll()
		
		#var time:LocalTime = LocalTime.now()
		#while true:
		#	# poll every 3s to hold the connection to the server
		#	if time.elapsed_since_ms() > 200:
		#		multiplayer.poll()
		#		#prints("poll network", self, multiplayer, multiplayer.network_peer.get_connection_status())
		#		time = LocalTime.now()

class_name GdUnitTcpClient
extends Node

signal connection_succeeded(message)
signal connection_failed(message)

# connetion timeout in ms
var _connection_timeout = 2.000
var _timer :Timer

var _host :String
var _port :int
var _client_id :int
var _connected :bool
var _stream :StreamPeerTCP

func _ready():
	_connected = false
	_stream = StreamPeerTCP.new()
	_timer = Timer.new()
	add_child(_timer)
	_timer.set_one_shot(true)
	var _x = _timer.connect('timeout', self, '_connecting_timeout')

func stop() -> void:
	console("Client: disconnect from server")
	if _stream != null:
		rpc_send(RPCClientDisconnect.new().with_id(_client_id))
	if _stream != null:
		_stream.disconnect_from_host()
	_connected = false

func start(host :String, port :int) -> Result:
	_host = host
	_port = port
	if _connected:
		return Result.warn("Client already connected ... %s:%d" % [_host, _port])
	
	# Connect client to server
	if not _stream.is_connected_to_host():
		var err := _stream.connect_to_host(host, port)
		if err != OK:
			return Result.error("GdUnit3: Can't establish client, error code: %s" % err)
	return Result.success("GdUnit3: Client connected on port %d" % port)

func _process(_delta):
	match _stream.get_status():
		StreamPeerTCP.STATUS_NONE:
			return
		
		StreamPeerTCP.STATUS_CONNECTING:
			set_process(false)
			console("Connecting...  %s:%d" % [_host, _port])
			# wait until client is connected to server
			for retry in 10:
				console("wait to connect ..")
				if _stream.get_status() == StreamPeerTCP.STATUS_CONNECTING:
					yield(get_tree().create_timer(0.500), "timeout")
				if _stream.get_status() == StreamPeerTCP.STATUS_CONNECTED:
					set_process(true)
					return
			set_process(true)
			_stream.disconnect_from_host()
			console("connection failed")
			emit_signal("connection_failed", "Connect to TCP Server %s:%d faild!" % [_host, _port])
		
		StreamPeerTCP.STATUS_CONNECTED:
			if not _connected:
				console("state Connected")
				var rpc
				set_process(false)
				while rpc == null:
					yield(get_tree().create_timer(0.500), "timeout")
					rpc = rpc_receive()
				set_process(true)
				_client_id = rpc.client_id()
				console("Connected to Server: %d" % _client_id)
				emit_signal("connection_succeeded", "Connect to TCP Server %s:%d success." % [_host, _port])
				_connected = true
			process_rpc()
		
		StreamPeerTCP.STATUS_ERROR:
			_stream.disconnect_from_host()
			console("connection failed")
			emit_signal("connection_failed", "Connect to TCP Server %s:%d faild!" % [_host, _port])
			return

func is_client_connected() -> bool:
	return _connected

func process_rpc() -> void:
	if _stream.get_available_bytes() > 0:
		var rpc = RPC.deserialize(_stream.get_var())
		if rpc is RPCClientDisconnect:
			stop()

func rpc_send(rpc :RPC) -> void:
	if _stream != null:
		_stream.put_data(("%s|" % rpc.serialize()).to_ascii())

func rpc_receive() -> RPC:
	if _stream != null:
		while _stream.get_available_bytes() > 0:
			return RPC.deserialize(_stream.get_var(true))
	return null

func console(message :String) -> void:
	#prints(message)
	pass

func _on_connection_failed(message :String):
	console("connection faild: " + message)

func _on_connection_succeeded(message :String):
	console("connected: " + message)

tool
class_name Network
extends Node


signal server_message
signal client_connected
signal client_disconnected

const DEFAULT_SERVER_START_RETRY_TIMES = 5
const GD_TEST_SERVER_PORT :int = 31002
const CLIENT_MAX_COUNT :int = 5

var _context = "Server"
var _connected :bool = false
var _connected_clients = Dictionary()

var _peer := NetworkedMultiplayerENet.new()

func _exit_tree():
	close()

func start_server() -> Result:
	_peer.connect("peer_connected",    self, "_peer_connected"   )
	_peer.connect("peer_disconnected", self, "_peer_disconnected")
	_peer.allow_object_decoding = true
	
	var err := OK
	var server_port := GD_TEST_SERVER_PORT
	for retry in DEFAULT_SERVER_START_RETRY_TIMES:
		err = _peer.create_server(server_port, CLIENT_MAX_COUNT)
		if err != OK:
			prints("GdUnit3: Can't establish server on port %d, error code: %s" % [server_port, err])
			server_port += 1
			prints("GdUnit3: Retry (%d) ..." % retry)
		else:
			break
	if err != OK:
		if err == ERR_ALREADY_IN_USE:
			return Result.error("GdUnit3: Can't establish server, error code: %s, The server is already in use" % err)
		return Result.error("GdUnit3: Can't establish server, error code: %s" % err)
	get_tree().set_network_peer(_peer)
	prints("GdUnit3: Server successfully started on port %d" % server_port)
	return Result.success(server_port)

func connect_client(port :int) -> Result:
	_context = "Client"
	_peer.connect("connection_succeeded",    self, "_on_connection_succeeded"   )
	_peer.connect("connection_failed", self, "_on_connection_failed")
	_peer.allow_object_decoding = true

	prints("GdUnit3: Connect to test server 127.0.0.1:%d" % port)
	var err :=  _peer.create_client("127.0.0.1", port)
	if err != OK:
		return Result.error("GdUnit3: Can't establish client, error code: %s" % err)
	get_tree().set_network_peer(_peer)
	return Result.success("GdUnit3: Client connected on port %d" % port)

func close():
	if is_client_connected():
		_peer.close_connection()
	get_tree().set_network_peer(null)

func disconnect_client(client_id :int):
	# only disconnect connected clients
	if _connected_clients[client_id]:
		_peer.disconnect_peer(client_id, true)

func is_client_connected() -> bool:
	return _connected

# signal handling
func _peer_connected(peer_id :int):
	_connected = true
	_connected_clients[peer_id] = true
	emit_signal("client_connected", peer_id)

func _peer_disconnected(peer_id :int):
	_connected = false
	_connected_clients[peer_id] = false
	emit_signal("client_disconnected", peer_id)

func _on_connection_succeeded():
	_connected = true

func _on_connection_failed():
	_connected = false
	push_error("GdUnit: connection to server failed")

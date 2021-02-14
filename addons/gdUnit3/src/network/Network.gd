tool
class_name Network
extends Node


signal server_message
signal client_connected
signal client_disconnected

const GD_TEST_SERVER_PORT :int = 31002
const CLIENT_MAX_COUNT :int = 5

var _context = "Server"
var _connected :bool = false
var _connected_clients = Dictionary()

var _peer := NetworkedMultiplayerENet.new()

func _exit_tree():
	close()

func start_server() -> void:
	_peer.connect("peer_connected",    self, "_peer_connected"   )
	_peer.connect("peer_disconnected", self, "_peer_disconnected")
	_peer.allow_object_decoding = true
	
	var err := _peer.create_server(GD_TEST_SERVER_PORT, CLIENT_MAX_COUNT)
	if err != OK:
		if err == ERR_ALREADY_IN_USE:
			push_error("Can't establish server, error code: %s, The server is already in use" % err)
			return
		push_error("Can't establish server, error code: %s" % err)
		return
	get_tree().set_network_peer(_peer)

func connect_client() -> void:
	_context = "Client"
	_peer.connect("connection_succeeded",    self, "_on_connection_succeeded"   )
	_peer.connect("connection_failed", self, "_on_connection_failed")
	_peer.allow_object_decoding = true

	var err :=  _peer.create_client("127.0.0.1", GD_TEST_SERVER_PORT)
	if err != OK:
		if err == ERR_ALREADY_IN_USE:
			push_error("Can't establish server, error code: %s, The server is already in use" % err)
			return
		push_error("Can't establish server, error code: %s" % err)
		return
	get_tree().set_network_peer(_peer)

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

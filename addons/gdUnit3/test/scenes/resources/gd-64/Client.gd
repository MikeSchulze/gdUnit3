class_name Client 
extends Node
	
signal done
var network = NetworkedMultiplayerENet.new()
var multiplayerAPI = MultiplayerAPI.new()

var ip = "127.0.0.1"
var port = 1911
var temp_node = null

func _ready():
	temp_node = Node.new()
	add_child(temp_node)
	
func _process(delta):
	#check whether custom multiplayer api is set
	if  get_custom_multiplayer() == null:
		return
	#check whether custom multiplayer network is set
	if not custom_multiplayer.has_network_peer():
		return
	#start custom_multiplayer poll
	custom_multiplayer.poll()

func StartClient():
	print("started")
	#connect signals
	network.connect("connection_failed" ,self ,"_OnConnectionFailed")
	network.connect("connection_succeeded" ,self ,"_OnConnectionSucceeded")
	var err = network.create_client(ip ,port)
	if err != OK:
		prints("Clinet failed", err)
		return
	set_custom_multiplayer(multiplayerAPI)
	custom_multiplayer.set_root_node(temp_node)
	custom_multiplayer.set_network_peer(network)
	emit_signal("done")

func _OnConnectionFailed():
	pass
	
func _OnConnectionSucceeded():
	pass

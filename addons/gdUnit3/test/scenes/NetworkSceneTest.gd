# GdUnit generated TestSuite
class_name NetworkServerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/test/scenes/resources/gd-64/Server.gd'

var _spy_server = null

func before():
	# using 'before()' to create only once the _spy_server at beginning of test suite run
	var scene_instance = load("res://addons/gdUnit3/test/scenes/resources/gd-64/Server.tscn").instance()
	# create a spy on this _spy_server instance
	_spy_server = spy(scene_instance)

func after():
	pass

func test_StartServer() -> void:
	scene_runner(_spy_server)
	verify(_spy_server).emit_signal("hello")
	
	prints("scene runns")
	
	var client :Client = spy(auto_free(Client.new()))
	add_child(client)
	client.StartClient()
	verify(client).emit_signal("done")
	# give client time to connect
	yield(get_tree().create_timer(0.3), "timeout")
	
	verify(client)._OnConnectionSucceeded()
	verify(_spy_server)._Peer_Connected(any_int())
	remove_child(client)

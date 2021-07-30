# GdUnit generated TestSuite
class_name RoomWithDoorTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://gdUnit3-examples/RoomDemo3D/src/rooms/RoomWithDoor.gd'

var _runner :GdUnitSceneRunner
var _scene: Node
var _door: Door
var _player :Player

func before_test() -> void:
	# we use before_test to have this code only once and reuse for each test
	_scene = spy("res://gdUnit3-examples/RoomDemo3D/src/rooms/RoomWithDoor.tscn")
	_runner = scene_runner(_scene)
	# set time factor to 10 to simulate the scene very fast
	_runner.set_time_factor(10)
	# enable this line to show the running scene during test execution
	_runner.maximize_view()
	# door not cloesed yet
	verify(_scene, 0)._on_door_door_closed(any())
	_door = _scene.find_node("door")
	_player = _scene.find_node("player")
	# door is initial started to closing
	assert_int(_door.state()).is_equal(Door.STATE.START_CLOSE)

# this example using simulate frames with a delta time peer frame
# ! the time factor is ignoring when using `simulate(frames: int, delta_peer_frame :float)`
# this test shows the inital scene, the door is open and auto closed on startup
func test_simulate_scene_by_frames_and_delta() -> void:
	# run the scene for 10 frames each frame with a delta of 10ms
	yield(_runner.simulate(10, .010), "completed")
	# the door is not closed yet, it is sill in closing animation
	assert_int(_door.state()).is_equal(Door.STATE.START_CLOSE)
	verify(_scene, 0)._on_door_door_closed(any())
	
	# run next 50 frames, the door should be closed after 50 frames
	yield(_runner.simulate(50, .010), "completed")
	# verify the door is closed by the `_on_door_door_closed` is called
	assert_int(_door.state()).is_equal(Door.STATE.CLOSE)
	verify(_scene, 1)._on_door_door_closed(any())

# this test shows the inital scene, the door is open and auto closed on startup
func test_simulate_scene_by_frames_with_time_shift() -> void:
	# run the scene for 10 frames
	yield(_runner.simulate_frames(10), "completed")
	# the door is not closed yet, it is sill in closing animation
	assert_int(_door.state()).is_equal(Door.STATE.START_CLOSE)
	verify(_scene, 0)._on_door_door_closed(any())
	
	# run next 50 frames
	yield(_runner.simulate_frames(50), "completed")
	# verify the door is closed by the `_on_door_door_closed` is called
	assert_int(_door.state()).is_equal(Door.STATE.CLOSE)
	verify(_scene, 1)._on_door_door_closed(any())

# this test runs the inital scene, and waits for the door close signal to stop the simulate
# additional we set the maximum test execution  timeout to 2s to abort at least after 2s
func test_simulate_until_signal(timeout = 2000) -> void:
	# run the scene until  the signal 'door_closed' is emited
	yield(_runner.simulate_until_signal("door_closed"), "completed")
	# verify the door is closed
	assert_int(_door.state()).is_equal(Door.STATE.CLOSE)
	verify(_scene, 1)._on_door_door_closed(any())

# this test moves the play in the door trigger arera to trigger an door open
func test_simulate_trigger_open_door(timeout = 5000) -> void:
	# wait until the door is closed
	yield(_runner.simulate_until_signal("door_closed"), "completed")
	assert_int(_door.state()).is_equal(Door.STATE.CLOSE)
	
	# move the player short before open door trigger areaa
	_player.transform.origin.z -= 3
	# continue scene runnung and weit for 60 frames 
	yield(_runner.simulate_frames(60), "completed")
	assert_int(_door.state()).is_equal(Door.STATE.CLOSE)
	
	# one step more and the door should be start to open
	_player.transform.origin.z -= .7
	# continue scene runnung for 10 frames the open animation shold be started
	yield(_runner.simulate_frames(10), "completed")
	assert_int(_door.state()).is_equal(Door.STATE.START_OPEN)
	
	# finally we wait for the door open is completes
	yield(_runner.simulate_until_signal("door_opened"), "completed")

# this test moves the play in the door trigger arera to trigger an door open
func test_simulate_process_pyhysics() -> void:
	var sponge = _scene.find_node("sponge")
	# the sponge is falling down
	assert_bool(sponge.is_sleeping()).is_false()
	# run 500 frames, time enough to bring the sponge down to the floor
	yield(_runner.simulate_frames(500), "completed")
	
	# the sponge should now be stay on the floor
	assert_bool(sponge.is_sleeping()).is_true()

# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdUnitAwaiterTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/GdUnitAwaiter.gd'

signal test_signal_a()
signal test_signal_b()
signal test_signal_c(value)
signal test_signal_d(value_a, value_b)

func after_test():
	for node in get_children():
		if node is Timer:
			remove_child(node)
			node.stop()
			node.free()

func install_signal_emitter(signal_name :String, signal_args: Array = [], time_out : float = .200):
	var timer := Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "emit_test_signal", [signal_name, signal_args])
	timer.start(time_out)

func emit_test_signal(signal_name :String, signal_args: Array):
	match signal_args.size():
		0: emit_signal(signal_name)
		1: emit_signal(signal_name, signal_args[0])
		2: emit_signal(signal_name, signal_args[0], signal_args[1])
		3: emit_signal(signal_name, signal_args[0], signal_args[1], signal_args[2])

func test_await_signal_on() -> void:
	install_signal_emitter("test_signal_a")
	yield(await_signal_on(self, "test_signal_a", [], 300), "completed")
	
	install_signal_emitter("test_signal_b")
	yield(await_signal_on(self, "test_signal_b", [], 300), "completed")
	
	install_signal_emitter("test_signal_c", [])
	yield(await_signal_on(self, "test_signal_c", [], 300), "completed")
	
	install_signal_emitter("test_signal_c", ["abc"])
	yield(await_signal_on(self, "test_signal_c", ["abc"], 300), "completed")
	
	install_signal_emitter("test_signal_c", ["abc", "eee"])
	yield(await_signal_on(self, "test_signal_c", ["abc", "eee"], 300), "completed")

func test_await_signal_on_manysignals_emitted() -> void:
	# emits many different signals
	install_signal_emitter("test_signal_a", [], .100)
	install_signal_emitter("test_signal_a", [], .200)
	install_signal_emitter("test_signal_a", [], .250)
	install_signal_emitter("test_signal_c", ["xxx"], .250)
	# the signal we want to wait for
	install_signal_emitter("test_signal_c", ["abc"], .350)
	install_signal_emitter("test_signal_c", ["yyy"], .350)
	
	# we only wait for 'test_signal_c("abc")' is emitted
	yield(await_signal_on(self, "test_signal_c", ["abc"], 400), "completed")

func test_await_signal_on_never_emitted_timedout() -> void:
	# we expect 'await_signal_on' will fail, do not report as failure
	GdAssertReports.expect_fail()
	# we  wait for 'test_signal_c("yyy")' which  is never emitted
	yield(await_signal_on(self, "test_signal_c", ["yyy"], 400), "completed")
	# expect is failed by a timeout at line 68
	if assert_failed_at(68, "await_signal_on(test_signal_c, [yyy]) timed out after 400ms"):
		return
	fail("test should failed after 400ms on 'await_signal_on'")

func test_await_signal_on_invalid_source_timedout() -> void:
	# we expect 'await_signal_on' will fail, do not report as failure
	GdAssertReports.expect_fail()
	# we  wait for a signal on a already freed instance
	yield(await_signal_on(invalid_node(), "tree_entered", [], 300), "completed")
	if assert_failed_at(78, "await_signal_on(Null, tree_entered, []) failed the source is invalid"):
		return
	fail("test should failed after 400ms on 'await_signal_on'")

func invalid_node() -> Node:
	var node = Node.new()
	node.free()
	return node

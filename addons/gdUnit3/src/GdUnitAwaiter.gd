class_name GdUnitAwaiter
extends Reference

# Waits for given signal is emited by the <source> until a specified timeout to fail
# source: the object from which the signal is emitted
# signal_name: signal name
# args: the expected signal arguments as an array
# timeout: the timeout in ms, default is set to 2000ms
static func await_signal_on(source :Object, signal_name :String, args :Array = [], timeout_millis :int = 2000) -> GDScriptFunctionState:
	var awaiter = GdUnitSignalAwaiter.new(timeout_millis)
	yield(awaiter.on_signal(source, signal_name, args), "completed")
	if awaiter.is_interrupted():
		# TODO add failure report!!!
		prints("interruped await_signal_on", signal_name, args, timeout_millis, "ms")
	return

# Waits for for a given amount of milliseconds
# example:
#    # waits for 100ms
#    yield(GdUnitAwaiter.await_millis(myNode, 100), "completed")
# use this waiter and not `yield(get_tree().create_timer(), "timeout") to prevent errors when a test case is timed out
static func await_millis(parent: Node, milliSec :int) -> GDScriptFunctionState:
	var timer :Timer = parent.auto_free(Timer.new())
	parent.add_child(timer)
	timer.set_one_shot(true)
	timer.start(milliSec * 0.001)
	return yield(timer, "timeout")

# Waits until the next idle frame
static func await_idle_frame() -> GDScriptFunctionState:
	return yield(Engine.get_main_loop(), "idle_frame")

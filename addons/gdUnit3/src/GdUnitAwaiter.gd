class_name GdUnitAwaiter
extends Reference


# Waits for a specified signal in an interval of 50ms sent from the <source>, and terminates with an error after the specified timeout has elapsed.
# source: the object from which the signal is emitted
# signal_name: signal name
# args: the expected signal arguments as an array
# timeout: the timeout in ms, default is set to 2000ms
static func await_signal_on(test_suite :WeakRef, source :Object, signal_name :String, args :Array = [], timeout_millis :int = 2000) -> GDScriptFunctionState:
	var line_number := GdUnitAssertImpl._get_line_number();
	var awaiter = GdUnitSignalAwaiter.new(timeout_millis)
	var value = yield(awaiter.on_signal(source, signal_name, args), "completed")
	if awaiter.is_interrupted():
		var failure = "await_signal_on(%s, %s) timed out after %sms" % [signal_name, args, timeout_millis]
		GdUnitAssertImpl.new(test_suite.get_ref(), signal_name).report_error(failure, line_number)
	return value

# Waits for a specified signal sent from the <source> between idle frames and aborts with an error after the specified timeout has elapsed
# source: the object from which the signal is emitted
# signal_name: signal name
# args: the expected signal arguments as an array
# timeout: the timeout in ms, default is set to 2000ms
static func await_signal_idle_frames(test_suite :WeakRef, source :Object, signal_name :String, args :Array = [], timeout_millis :int = 2000) -> GDScriptFunctionState:
	var line_number := GdUnitAssertImpl._get_line_number();
	var awaiter = GdUnitSignalAwaiter.new(timeout_millis, true)
	yield(awaiter.on_signal(source, signal_name, args), "completed")
	if awaiter.is_interrupted():
		var failure = "await_signal_idle_frames(%s, %s) timed out after %sms" % [signal_name, args, timeout_millis]
		GdUnitAssertImpl.new(test_suite.get_ref(), signal_name).report_error(failure, line_number)
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

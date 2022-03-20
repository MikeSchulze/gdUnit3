class_name GdUnitAwaiter
extends Reference


const NO_ARG = "<--null-->"

# waits for a signal on given source and matching signal arguments
static func doAwaitOnSignal(source :Object, signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG) -> GDScriptFunctionState:
	var signal_args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5], NO_ARG)
	prints("awaitOnSignal", source, signal_name, signal_args)
	if signal_args.empty():
		return yield(doAwaitOnSignal(source, signal_name), "completed")
	var args = yield(source, signal_name)
	if not (args is Array):
		args = [args]
	if GdObjects.equals(args, signal_args):
		return null
	return yield(doAwaitOnSignal(source, signal_name, arg0, arg1, arg2, arg3, arg4, arg5), "completed")


# waits for for a given amount of milliseconds
# example:
#    # waits for 100ms
#    yield(GdUnitAwaiter.doAwaitOnMillis(self, 100), "completed")
# use this waiter and not `yield(get_tree().create_timer(), "timeout") to prevent errors when a test case is timed out
static func doAwaitOnMillis(test_suite: Node, milliSec :int) -> Timer:
	var timer :Timer = test_suite.auto_free(Timer.new())
	test_suite.add_child(timer)
	timer.set_one_shot(true)
	timer.start((milliSec/1000.0))
	return yield(timer, "timeout")

# waits until next idle frame
static func doAwaitOnIdleFrame() -> GDScriptFunctionState:
	return yield(Engine.get_main_loop(), "idle_frame")

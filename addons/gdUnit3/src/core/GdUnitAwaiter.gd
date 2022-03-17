class_name GdUnitAwaiter
extends Reference


const NO_ARG = "<--null-->"

# waits for a signal on given source and matching signal arguments
static func awaitOnSignal(source :Object, signal_name :String, arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG) -> GDScriptFunctionState:
	var signal_args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5], NO_ARG)
	prints("awaitOnSignal", source, signal_name, signal_args)
	if signal_args.empty():
		return yield(awaitOnSignal(source, signal_name), "completed")
	var args = yield(source, signal_name)
	if not (args is Array):
		args = [args]
	if GdObjects.equals(args, signal_args):
		return null
	return yield(awaitOnSignal(source, signal_name, arg0, arg1, arg2, arg3, arg4, arg5), "completed")

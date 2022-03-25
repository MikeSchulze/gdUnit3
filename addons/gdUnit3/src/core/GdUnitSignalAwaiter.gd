class_name GdUnitSignalAwaiter
extends Reference

const NO_ARG = GdUnitConstants.NO_ARG

signal signal_emitted

var TIMER_AWAKE = Reference.new()
var TIMER_INTERRUPTED = Reference.new()
var timer = Timer.new()
var sleep := Timer.new()
var _interrupted := false
var _time_left := 0

func _init(timeout_millis :int):
	Engine.get_main_loop().root.add_child(timer)
	Engine.get_main_loop().root.add_child(sleep)
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_on_timeout")
	timer.start(timeout_millis * 0.001 * Engine.get_time_scale())
	sleep.connect("timeout", self, "_on_sleep_awakening")
	sleep.start(0.05)

func _on_sleep_awakening():
	call_deferred("emit_signal", "signal_emitted", TIMER_AWAKE)

func _on_timeout():
	_interrupted = true
	call_deferred("emit_signal", "signal_emitted", TIMER_INTERRUPTED)

func _on_signal_emmited(arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	var signal_args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	call_deferred("emit_signal", "signal_emitted", signal_args)

func is_interrupted() -> bool:
	return _interrupted

func elapsed_time() -> int:
	return _time_left

func on_signal(source :Object, signal_name :String, signal_args :Array):
	# register on signal to wait for
	source.connect(signal_name, self, "_on_signal_emmited")
	
	while not _interrupted:
		var value = yield(self, "signal_emitted")
		if value is Reference and (value == TIMER_AWAKE or value == TIMER_INTERRUPTED):
			continue
		if not (value is Array):
			value = [value]
		if GdObjects.equals(value, signal_args):
			break
	# stop/cleanup timers
	_time_left = timer.time_left# / Engine.get_time_scale()
	timer.stop()
	sleep.stop()
	Engine.get_main_loop().root.remove_child(timer)
	Engine.get_main_loop().root.remove_child(sleep)
	timer.free()
	sleep.free()

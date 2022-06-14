class_name GdUnitSignalAwaiter
extends Reference

const NO_ARG = GdUnitConstants.NO_ARG

signal signal_emitted(action)

var TIMER_AWAKE = Reference.new()
var TIMER_INTERRUPTED = Reference.new()
var _wait_on_idle_frame = false
var _interrupted := false
var _time_left := 0
var _timeout_millis

func _init(timeout_millis :int, wait_on_idle_frame := false):
	_timeout_millis = timeout_millis
	_wait_on_idle_frame = wait_on_idle_frame

func _on_sleep_awakening():
	call_deferred("emit_signal", "signal_emitted", TIMER_AWAKE)

func _on_timeout():
	call_deferred("emit_signal", "signal_emitted", TIMER_INTERRUPTED)

func _on_signal_emmited(arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	var signal_args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	call_deferred("emit_signal", "signal_emitted", signal_args)

func is_interrupted() -> bool:
	return _interrupted

func elapsed_time() -> int:
	return _time_left

func on_signal(source :Object, signal_name :String, expected_signal_args :Array):
	# register on signal to wait for
	source.connect(signal_name, self, "_on_signal_emmited")
	# install timeout timer
	var timer = Timer.new()
	Engine.get_main_loop().root.add_child(timer)
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_on_timeout")
	timer.start(_timeout_millis * 0.001 * Engine.get_time_scale())
	# install sleep timer with a time of 50ms between the signal received checks
	# the sleep timer is need to give engine main loop time to process
	# if _wait_on_idle_frame set than we skip wait time and wait instead for next idle frame
	var sleep_time = 0.0001 if _wait_on_idle_frame else 0.05
	var sleep := Timer.new()
	Engine.get_main_loop().root.add_child(sleep)
	sleep.connect("timeout", self, "_on_sleep_awakening")
	sleep.start(sleep_time)
	
	# holds the emited value
	var value
	# wait for signal is emitted or a timeout is happen
	while true:
		if _wait_on_idle_frame:
			yield(Engine.get_main_loop(), "idle_frame")
		value = yield(self, "signal_emitted")
		if value is Reference and value == TIMER_INTERRUPTED:
			_interrupted = true
			break
		if value is Reference and value == TIMER_AWAKE:
			continue
		if not (value is Array):
			value = [value]
		if expected_signal_args.size() == 0 or GdObjects.equals(value, expected_signal_args):
			break
	
	# stop/cleanup timers
	_time_left = timer.time_left
	timer.stop()
	Engine.get_main_loop().root.remove_child(timer)
	timer.free()
	sleep.stop()
	Engine.get_main_loop().root.remove_child(sleep)
	sleep.free()
	if value is Array and value.size() == 1:
		return value[0]
	return value

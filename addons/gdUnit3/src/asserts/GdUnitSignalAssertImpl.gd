class_name GdUnitSignalAssertImpl
extends GdUnitSignalAssert

signal signal_emitted(value)

const DEFAULT_TIMEOUT := 2000
const NO_ARG = "<--null-->"

var _instance :Object
var _current_error_message = null
var _custom_failure_message = null
var _line_number := -1
var _expect_fail := false
var _is_failed := false
var _timeout := DEFAULT_TIMEOUT
var _expect_result :int
var _report_consumer : GdUnitReportConsumer
var _caller : WeakRef
var _interrupted := false


func _init(caller :WeakRef, instance :Object, expect_result := EXPECT_SUCCESS):
	_line_number = GdUnitAssertImpl._get_line_number()
	_caller = caller
	_instance =  instance
	_expect_result = expect_result
	GdAssertReports.reset_last_error_line_number()
	# set report consumer to be use to report the final result
	_report_consumer = caller.get_ref().get_meta(GdUnitReportConsumer.META_PARAM)
	# we expect the test will fail
	if expect_result == EXPECT_FAIL:
		_expect_fail = true

func report_success() -> GdUnitAssert:
	return GdAssertReports.report_success(self)

func report_error(error_message :String) -> GdUnitAssert:
	if _custom_failure_message == null:
		return GdAssertReports.report_error(error_message, self, _line_number)
	return GdAssertReports.report_error(_custom_failure_message, self, _line_number)

func send_report(report :GdUnitReport)-> void:
	if is_instance_valid(_report_consumer):
		_report_consumer.consume(report)

# -------- Base Assert wrapping ------------------------------------------------
func has_failure_message(expected: String) -> GdUnitSignalAssert:
	var current_error := _extract_plain_message(_current_error_message)
	if current_error != expected:
		_expect_fail = false
		var diffs := GdObjects.string_diff(current_error, expected)
		var current := GdAssertMessages.colorDiff(diffs[1])
		_custom_failure_message = null
		report_error(GdAssertMessages.error_not_same_error(current, expected))
	return self

func starts_with_failure_message(expected: String) -> GdUnitSignalAssert:
	var current_error := _extract_plain_message(_current_error_message)
	if not current_error.begins_with(expected):
		_expect_fail = false
		var diffs := GdObjects.string_diff(current_error, expected)
		var current := GdAssertMessages.colorDiff(diffs[1])
		_custom_failure_message = null
		report_error(GdAssertMessages.error_not_same_error(current, expected))
	return self

func _extract_plain_message(message) -> String:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.parse_bbcode(message if message else "")
	rtl.queue_free()
	return rtl.get_text()

func override_failure_message(message :String) -> GdUnitSignalAssert:
	_custom_failure_message = message
	return self

func wait_until(timeout := 2000) -> GdUnitSignalAssert:
	if timeout <= 0:
		push_warning("Invalid timeout param, alloed timeouts must be grater than 0. Use default timeout instead")
		_timeout = DEFAULT_TIMEOUT
	else:
		_timeout = timeout
	return self

# Verifies that given signal is emitted until waiting time
func is_emitted(name :String, args := []) -> GdUnitSignalAssert:
	return _wail_until_signal(name, args, false)

# Verifies that given signal is NOT emitted until waiting time
func is_not_emitted(name :String, args := []) -> GdUnitSignalAssert:
	return _wail_until_signal(name, args, true)

func _verify_signal_args(current :Array, expected :Array) -> bool:
	return  GdObjects.equals(current, expected)

func _wail_until_signal(signal_name :String, expected_args :Array, expect_not_emitted: bool):
	if _instance == null:
		report_error("Can't wait for signal on a NULL object.")
		yield(Engine.get_main_loop(), "idle_frame")
		return self
	# first verify the signal to wait is defined
	if not _instance.has_signal(signal_name):
		report_error("Can't wait for non-existion signal '%s' on object '%s'." % [signal_name,_instance.get_class()])
		yield(Engine.get_main_loop(), "idle_frame")
		return self
	# register on signal to wait for
	_instance.connect(signal_name, self, "_on_signal_emmited")
	var caller = _caller.get_ref()
	var time_scale = Engine.get_time_scale()
	var timeout = Timer.new()
	caller.add_child(timeout)
	timeout.set_one_shot(true)
	timeout.connect("timeout", self, "_on_timeout")
	timeout.start((_timeout/1000.0)*time_scale)
	# sleep timer
	var sleep := Timer.new()
	caller.add_child(sleep)
	sleep.start(0.05)
	sleep.set_autostart(true)
	sleep.connect("timeout", self, "_on_sleep_awakening")
	
	while not _interrupted:
		var current_args = yield(self, "signal_emitted")
		# no signal was catched because of timeout or just sleep interupt
		if current_args == null:
			continue
		var is_signal_emitted = _verify_signal_args(current_args, expected_args)
		if is_signal_emitted:
			if expect_not_emitted:
				report_error(GdAssertMessages.error_signal_emitted(signal_name, current_args, LocalTime.elapsed(_timeout-timeout.time_left*1000)))
			break
	
	if _interrupted and not expect_not_emitted:
		report_error(GdAssertMessages.error_wait_signal(signal_name, expected_args, LocalTime.elapsed(_timeout)))
		
	sleep.stop()
	sleep.queue_free()
	timeout.queue_free()
	dispose()
	return self

func _on_signal_emmited(arg0=NO_ARG, arg1=NO_ARG, arg2=NO_ARG, arg3=NO_ARG, arg4=NO_ARG, arg5=NO_ARG, arg6=NO_ARG, arg7=NO_ARG, arg8=NO_ARG, arg9=NO_ARG):
	var signal_args = GdObjects.array_filter_value([arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9], NO_ARG)
	call_deferred("emit_signal", "signal_emitted", signal_args)

func _on_sleep_awakening():
	call_deferred("emit_signal", "signal_emitted", null)

func _on_timeout():
	_interrupted = true
	call_deferred("emit_signal", "signal_emitted", null)

# it is important to free all references/connections to prevent orphan nodes
func dispose():
	disconnect_connections(self)
	_caller = null

func disconnect_connections(obj :Object):
	if is_instance_valid(obj):
		# disconnect from all connected signals to force freeing, otherwise it ends up in orphans
		for connection in obj.get_incoming_connections():
			var source_ :Object = connection["source"]
			var signal_ :String = connection["signal_name"]
			var method_name_ :String = connection["method_name"]
			source_.disconnect(signal_, obj, method_name_)

class_name _TestCase
extends Node

# default timeout 5min
const DEFAULT_TIMEOUT :int = 1000 * 60 * 5
const ARGUMENT_TIMEOUT := "timeout"

var _iterations: int = 1
var _seed: int
var _fuzzer_func: String = ""
var _line_number: int = -1
var _script_path: String
var _skipped := false
var _expect_to_interupt := false

var _timer : Timer = Timer.new()
var _fs
var _interupted :bool = false
var _timeout :int

func _init() -> void:
	add_child(_timer)
	_timer.set_one_shot(true)
	_timer.connect('timeout', self, '_test_case_timeout')

func configure(name: String, line_number: int, script_path: String, timeout :int = DEFAULT_TIMEOUT, fuzzer: String = "", iterations: int = 1, seed_ :int = -1, skipped := false) -> _TestCase:
	set_name(name)
	_line_number = line_number
	if not fuzzer.empty():
		_fuzzer_func = fuzzer
		_iterations = iterations
	_seed = seed_
	_script_path = script_path
	_skipped = skipped
	_timeout = timeout
	return self

func execute(fuzzer :Fuzzer = null) :
	if fuzzer:
		if fuzzer._iteration_index == 1:
			set_timeout()
		_fs = get_parent().call(name, fuzzer)
	else:
		set_timeout()
		_fs = get_parent().call(name)
	if GdUnitTools.is_yielded(_fs):
		yield(_fs, "completed")
	return _fs

func set_timeout():
	var time :float = _timeout / 1000.0
	#prints(get_name(), "set testcase timeout to %d ms" % _timeout)
	_timer.set_wait_time(time)
	_timer.set_autostart(false)
	_timer.start()

func _test_case_timeout():
	_interupted = true
	if _fs is GDScriptFunctionState:
		yield(get_tree(), "idle_frame")
		_fs.emit_signal("completed")

func is_interupted() -> bool:
	return _interupted

func expect_to_interupt() -> void:
	_expect_to_interupt = true

func is_expect_interupted() -> bool:
	 return _expect_to_interupt

func line_number() -> int:
	return _line_number

func iterations() -> int:
	return _iterations

func timeout() -> int:
	return _timeout

func seed_value() -> int:
	return _seed
	
func has_fuzzer() -> bool:
	return not _fuzzer_func.empty()
	
func fuzzer_func() -> String:
	return _fuzzer_func

func script_path() -> String:
	return _script_path
	
func generate_seed() -> void:
	if _seed != -1:
		seed(_seed)

func skip(skipped :bool) -> void:
	_skipped = skipped

func is_skipped() -> bool:
	return _skipped

static func serialize(test_case: _TestCase) -> Dictionary:
	var serialized := Dictionary()
	serialized["name"] = test_case.get_name()
	serialized["line_number"] = test_case.line_number()
	serialized["script_path"] = test_case.script_path()
	serialized["timeout"] = test_case.timeout()
	serialized["fuzzer"] = test_case.fuzzer_func()
	serialized["iterations"] = test_case.iterations()
	serialized["seed"] = test_case.seed_value()
	serialized["skipped"] = test_case.is_skipped()
	return serialized

static func deserialize(serialized: Dictionary) -> _TestCase:
	var instance = load("res://addons/gdUnit3/src/core/_TestCase.gd")
	return instance.new().configure(
		serialized["name"], 
		serialized["line_number"],
		serialized["script_path"],
		serialized["timeout"],
		serialized["fuzzer"],
		serialized["iterations"],
		serialized["seed"],
		serialized["skipped"])

func _to_string():
	return "%s :%d (%dms)" % [get_name(), _line_number, _timeout]

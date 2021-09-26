class_name _TestCase
extends Node

# default timeout 5min
const DEFAULT_TIMEOUT := -1
const ARGUMENT_TIMEOUT := "timeout"

var _iterations: int = 1
var _seed: int
var _fuzzers: PoolStringArray = PoolStringArray()
var _line_number: int = -1
var _script_path: String
var _skipped := false
var _expect_to_interupt := false

var _timer : Timer = Timer.new()
var _fs
var _interupted :bool = false
var _timeout :int
var _default_timeout :int

func _init() -> void:
	add_child(_timer)
	_timer.set_one_shot(true)
	_timer.connect('timeout', self, '_test_case_timeout')
	_default_timeout = GdUnitSettings.test_timeout()

func configure(name: String, line_number: int, script_path: String, timeout :int = DEFAULT_TIMEOUT, fuzzers:= PoolStringArray(), iterations: int = 1, seed_ :int = -1, skipped := false) -> _TestCase:
	set_name(name)
	_line_number = line_number
	if not fuzzers.empty():
		_fuzzers = fuzzers
		_iterations = iterations
	_seed = seed_
	_script_path = script_path
	_skipped = skipped
	_timeout = _default_timeout
	if timeout != DEFAULT_TIMEOUT:
		_timeout = timeout
	return self

func execute(fuzzers := Array(), iteration := 0):
	if iteration == 0:
		set_timeout()
	if not fuzzers.empty():
		update_fuzzers(fuzzers, iteration)
		_fs = get_parent().callv(name, fuzzers)
	else:
		_fs = get_parent().call(name)
	if GdUnitTools.is_yielded(_fs):
		yield(_fs, "completed")
	return _fs

func update_fuzzers(fuzzers :Array, iteration :int):
	for fuzzer in fuzzers:
		fuzzer._iteration_index = iteration + 1

func set_timeout():
	var time :float = _timeout / 1000.0
	_timer.set_wait_time(time)
	_timer.set_autostart(false)
	_timer.start()

func _test_case_timeout():
	_timer.stop()
	_interupted = true
	if _fs is GDScriptFunctionState:
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
	return not _fuzzers.empty()
	
func fuzzers() -> PoolStringArray:
	return _fuzzers

func script_path() -> String:
	return _script_path
	
func generate_seed() -> void:
	if _seed != -1:
		seed(_seed)

func skip(skipped :bool) -> void:
	_skipped = skipped

func is_skipped() -> bool:
	return _skipped

func _to_string():
	return "%s :%d (%dms)" % [get_name(), _line_number, _timeout]

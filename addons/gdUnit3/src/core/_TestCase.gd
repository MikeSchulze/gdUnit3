class_name _TestCase
extends Node

var _iterations: int = 1
var _seed: int
var _fuzzer_func: String = ""
var _line_number: int = -1
var _script_path: String
var _annotations: Dictionary = {}
var _skipped := false

func _init(name: String, line_number: int, script_path: String, fuzzer: String = "", iterations: int = 1, seed_ :int = -1, skipped := false) -> void:
	set_name(name)
	_line_number = line_number
	if not fuzzer.empty():
		_fuzzer_func = fuzzer
		_iterations = iterations
	_seed = seed_
	_script_path = script_path
	_skipped = skipped

func line_number() -> int:
	return _line_number

func iterations() -> int:
	return _iterations

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
	serialized["fuzzer"] = test_case.fuzzer_func()
	serialized["iterations"] = test_case.iterations()
	serialized["seed"] = test_case.seed_value()
	serialized["skipped"] = test_case.is_skipped()
	return serialized

static func deserialize(serialized: Dictionary) -> _TestCase:
	var instance = load("res://addons/gdUnit3/src/core/_TestCase.gd")
	return instance.new(
		serialized["name"], 
		serialized["line_number"],
		serialized["script_path"],
		serialized["fuzzer"],
		serialized["iterations"],
		serialized["seed"],
		serialized["skipped"])

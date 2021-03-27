class_name CmdOptions
extends Reference


var OPTION_HELP = CmdOption.new("-?", "", "Shows this help message.")
var OPTION_ADVANCES_HELP = CmdOption.new("--?", "", "Shows advanced options.")
var _default_options :Array
var _advanced_options :Array


func _init(options :Array = Array(), advanced_options :Array = Array()):
	# default help options
	_default_options = [OPTION_HELP, OPTION_ADVANCES_HELP] + options 
	_advanced_options = advanced_options

func default_options() -> Array:
	return _default_options

func advanced_options() -> Array:
	return _advanced_options

func options() -> Array:
	return default_options() + advanced_options()

func get_option(cmd :String) -> CmdOption:
	for option in options():
		if option.commands().has(cmd):
			return option
	return null

func is_help(option :CmdOption) -> bool:
	return option == OPTION_HELP or option == OPTION_ADVANCES_HELP

func print_options(option :CmdOption = OPTION_HELP):
	prints("Usage: gdUnit -sd <directory> [-sd <directory>]... [-e <suite-name>]")
	prints("----------------------------------------------------------------------------------------------")
	for option in default_options():
		prints(option.describe())
	# print advance options
	prints("-- Advanced options --------------------------------------------------------------------------")
	if option == OPTION_ADVANCES_HELP:
		for option in advanced_options():
			prints(option.describe())

class_name CmdArgumentParser
extends Reference

var _options :CmdOptions
var _tool_name :String
var _parsed_commands :Dictionary = Dictionary()
var _show_help := true

func _init(options :CmdOptions, tool_name :String):
	_options = options
	_tool_name = tool_name

func parse(args :Array) -> int:
	_parsed_commands.clear()
	_show_help = true
	
	# parse until first program argument
	while not args.empty():
		var arg :String = args.pop_front()
		if arg.find(_tool_name):
			args.pop_front()
			break
	
	# if no arguments found show help by default
	if args.empty():
		_show_help = true
		_options.print_options()
		return 0
	
	# now parse all arguments
	while not args.empty():
		var cmd :String = args.pop_front()
		var option := _options.get_option(cmd)
		if _options.is_help(option):
			_options.print_options(option)
			return 0
		
		if option:
			if _parse_cmd_arguments(option, args) == -1:
				print_error("The '%s' command requires an argument!" % option.short_command())
				print_info(option.describe())
				return -1
		else:
			print_error("Unknown '%s' command!" % cmd)
			return -1
	_show_help = false
	return 0

func commands() -> Array:
	return _parsed_commands.values()

func _parse_cmd_arguments(option :CmdOption, args :Array) -> int:
	var command_name := option.short_command()
	var command :CmdCommand = _parsed_commands.get(command_name, CmdCommand.new(command_name))
	
	if option.has_argument():
		if not option.is_argument_optional() and args.empty():
			return -1
		if _is_next_value_argument(args):
			command.add_argument(args.pop_front())
		elif not option.is_argument_optional():
			return -1
	_parsed_commands[command_name] = command
	return 0

func _is_next_value_argument(args :Array) -> bool:
	if args.empty():
		return false
	return _options.get_option(args[0]) == null


static func print_error(message :String) -> void:
	prints("[0;91m%s[0m" % message)

static func print_info(message :String) -> void:
	prints("[0;92m%s[0m" % message)



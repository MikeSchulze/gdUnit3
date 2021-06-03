class_name CmdCommandHandler
extends Reference

const CB_SINGLE_ARG = 0
const CB_MULTI_ARGS = 1

var _cmd_options :CmdOptions
# holds the command callbacks by key:<cmd_name>:String and value: [<cb single arg>, <cb multible args>]:Array
var _command_func_refs :Dictionary

# we only able to check fr function name since Godot 3.3.x
var _enhanced_fr_test := false

func _init(cmd_options :CmdOptions):
	_cmd_options = cmd_options
	var major :int = Engine.get_version_info()["major"]
	var minor :int = Engine.get_version_info()["minor"]
	if major == 3 and minor == 3:
		_enhanced_fr_test = true

# register a callback function for given command
# cmd_name short name of the command
# fr_arg a funcref to a function with a single argument
func register_cb(cmd_name :String, fr :FuncRef) -> CmdCommandHandler:
	var registered_fr :Array = _command_func_refs.get(cmd_name, [null,null])
	if registered_fr[CB_SINGLE_ARG]:
		push_error("A function for command '%s' is already registered!" % cmd_name)
		return self
	registered_fr[CB_SINGLE_ARG] = fr
	_command_func_refs[cmd_name] = registered_fr
	return self

# register a callback function for given command
# fr a funcref to a function with a variable number of arguments but expects all parameters to be passed via a single Array.
func register_cbv(cmd_name :String, fr :FuncRef) -> CmdCommandHandler:
	var registered_fr :Array = _command_func_refs.get(cmd_name, [null, null])
	if registered_fr[CB_MULTI_ARGS]:
		push_error("A function for command '%s' is already registered!" % cmd_name)
		return self
	registered_fr[CB_MULTI_ARGS] = fr
	_command_func_refs[cmd_name] = registered_fr
	return self

func _validate() -> Result:
	var errors := PoolStringArray()
	var registers_func_cbs := Dictionary()
	
	for cmd_name in _command_func_refs.keys():
		var fr :FuncRef = _command_func_refs[cmd_name][CB_SINGLE_ARG] if _command_func_refs[cmd_name][CB_SINGLE_ARG] else _command_func_refs[cmd_name][CB_MULTI_ARGS]
		if fr == null:
			errors.append("Invalid function reference for command '%s', Null is not a allowed!" % cmd_name)
		elif not fr.is_valid():
			errors.append("Invalid function reference for command '%s', Check the function reference!" % cmd_name)
		if _cmd_options.get_option(cmd_name) == null:
			errors.append("The command '%s' is unknown, verify your CmdOptions!" % cmd_name)
		
		# verify for multiple registered command callbacks
		if _enhanced_fr_test and fr != null:
			var func_cb_name = fr.get_function()
			if registers_func_cbs.has(func_cb_name):
				var already_registered_cmd = registers_func_cbs[func_cb_name] 
				errors.append("The function reference '%s' already registerd for command '%s'!" % [func_cb_name, already_registered_cmd])
			else:
				registers_func_cbs[func_cb_name] = cmd_name
	
	if errors.empty():
		return Result.success(true)
	else:
		return Result.error(errors.join("\n"))

func execute(commands :Array) -> Result:
	var result := _validate()
	if result.is_error():
		return result
	
	for index in commands.size():
		var cmd :CmdCommand = commands[index]
		assert(cmd is CmdCommand, "commands contains invalid command object '%s'" % cmd)
		var cmd_name := cmd.name()
		if _command_func_refs.has(cmd_name):
			var fr_s :FuncRef = _command_func_refs.get(cmd_name)[CB_SINGLE_ARG]
			var fr_m :FuncRef = _command_func_refs.get(cmd_name)[CB_MULTI_ARGS]
			if cmd.arguments().empty():
				if fr_s == null:
					return Result.error("Invalid command callback for cmd '%s'" % cmd_name)
				fr_s.call_func()
			else:
				if cmd.arguments().size() == 1:
					if fr_s == null:
						return Result.error("Invalid command callback for cmd '%s'" % cmd_name)
					fr_s.call_func(cmd.arguments()[CB_SINGLE_ARG])
				else:
					if fr_m == null:
						return Result.error("Invalid command callback for cmd '%s'" % cmd_name)
					fr_m.call_func(cmd.arguments())
	return Result.success(true)

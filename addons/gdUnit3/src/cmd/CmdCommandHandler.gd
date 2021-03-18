class_name CmdCommandHandler
extends Reference

var _cmd_options :CmdOptions
var _command_func_refs :Dictionary

func _init(cmd_options :CmdOptions):
	_cmd_options = cmd_options

func register_cb(cmd_name :String, fr :FuncRef) -> void:
	if _command_func_refs.has(cmd_name):
		push_error("The command '%s' is already registered!" % cmd_name)
	_command_func_refs[cmd_name] = fr

func _validate() -> Result:
	var errors := PoolStringArray()
	var registers_func_cbs := Dictionary()
	
	for cmd_name in _command_func_refs.keys():
		var fr :FuncRef =_command_func_refs[cmd_name]
		if fr == null:
			errors.append("Invalid function reference for command '%s', Null is not a allowed!" % cmd_name)
		elif not fr.is_valid():
			errors.append("Invalid function reference for command '%s', Check the function reference!" % cmd_name)
		if _cmd_options.get_option(cmd_name) == null:
			errors.append("The command '%s' is unknown, verify your CmdOptions!" % cmd_name)
		
		# verify for multiple registered command callbacks
		if fr != null:
			var func_cb_name := fr.get_function()
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
			prints("execute cmd", cmd, "cb->", _command_func_refs.get(cmd_name))
			var fr :FuncRef = _command_func_refs.get(cmd_name)
			fr.call_func()
			
	
	return Result.success(true)
	

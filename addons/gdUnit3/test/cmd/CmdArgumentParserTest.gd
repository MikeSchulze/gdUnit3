# GdUnit generated TestSuite
class_name CmdArgumentParserTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/cmd/CmdArgumentParser.gd'

var option_a := CmdOption.new("-a", "some help text a", "some description a")
var option_f := CmdOption.new("-f, --foo", "some help text foo", "some description foo")
var option_b := CmdOption.new("-b, --bar", "-b <value>", "comand with required argument", TYPE_STRING)
var option_c := CmdOption.new("-c, --calc", "-c [value]", "command with optional argument", TYPE_STRING, true)
var option_x := CmdOption.new("-x", "some help text x", "some description x")

var _cmd_options :CmdOptions

func before():
	# setup command options
	_cmd_options = CmdOptions.new([
		option_a,
		option_f,
		option_b,
		option_c,
	], 
	# advnaced options
	[
		option_x,
	])


func test_parse_success():
	var parser := CmdArgumentParser.new(_cmd_options, "CmdTool.gd")
	# show help as default if not arguments set
	assert_bool(parser._show_help).is_true()
	assert_array(parser.commands()).is_empty()
	
	assert_int(parser.parse([])).is_zero()
	assert_bool(parser._show_help).is_true()
	assert_array(parser.commands()).is_empty()
	
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd"])).is_zero()
	assert_bool(parser._show_help).is_true()
	assert_array(parser.commands()).is_empty()
	
	# if valid argument set than don't show the help by default
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-a"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-a"),
	])

func test_parse_success_required_arg():
	var parser := CmdArgumentParser.new(_cmd_options, "CmdTool.gd")

	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-a", "-b", "value"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-a"),
		CmdCommand.new("-b", ["value"])
	])
	
	# useing command long term
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-a", "--bar", "value"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-a"),
		CmdCommand.new("-b", ["value"])
	])

func test_parse_success_optional_arg():
	var parser := CmdArgumentParser.new(_cmd_options, "CmdTool.gd")
	
	# without argument
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-c", "-a"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-c"),
		CmdCommand.new("-a")
	])
	
	# without argument at end
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-a", "-c"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-a"),
		CmdCommand.new("-c")
	])
	
	# with argument
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-c", "argument", "-a"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-c", ["argument"]),
		CmdCommand.new("-a")
	])

func test_parse_success_repead_cmd_args():
	var parser := CmdArgumentParser.new(_cmd_options, "CmdTool.gd")
	
	# without argument
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-c", "argument", "-a"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-c", ["argument"]),
		CmdCommand.new("-a")
	])
	
	# with repeading commands argument
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-c", "argument1", "-a",  "-c", "argument2",  "-c", "argument3"])).is_zero()
	assert_bool(parser._show_help).is_false()
	assert_array(parser.commands()).contains_exactly([
		CmdCommand.new("-c", ["argument1", "argument2", "argument3"]),
		CmdCommand.new("-a")
	])

func test_parse_error():
	var parser := CmdArgumentParser.new(_cmd_options, "CmdTool.gd")
	# show help as default if not arguments set
	assert_bool(parser._show_help).is_true()
	assert_array(parser.commands()).is_empty()
	
	assert_int(parser.parse([])).is_zero()
	assert_bool(parser._show_help).is_true()
	assert_array(parser.commands()).is_empty()
	
	# if invalid arguemens set than return with error and show the help by default
	assert_int(parser.parse(["-d", "dir/dir/CmdTool.gd", "-unknown"])).is_equal(-1)
	assert_bool(parser._show_help).is_true()
	assert_array(parser.commands()).is_empty()


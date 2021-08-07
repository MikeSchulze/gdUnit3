tool
extends Control


onready var header := $VBoxContainer/Header/header_title
onready var output := $VBoxContainer/Console/TextEdit

onready var _signal_handler:SignalHandler = GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)


func _ready():
	var config = ConfigFile.new()
	config.load('addons/gdUnit3/plugin.cfg')
	var version = config.get_value('plugin', 'version')
	_signal_handler.register_on_gdunit_events(self, "_on_event_test_suite")
	_signal_handler.register_on_message(self, "_on_message")
	_signal_handler.register_on_client_connected(self, "_on_client_connected")
	_signal_handler.register_on_client_disconnected(self, "_on_client_disconnected")

	header.bbcode_text = header.bbcode_text.replace('${version}', version)
	output.clear()

func _on_event_test_suite(event :GdUnitEvent):
	match event.type():
		GdUnitEvent.TESTSUITE_BEFORE:
			output.append_bbcode("Run Test Suite: %s" %  event._suite_name)
			output.newline()
		GdUnitEvent.TESTSUITE_AFTER:
			#output.append_bbcode("%-120s" % "FINISHED | PASSED:" + str(event._success_count) + "| FAILED:" + str(event._failed_count))
			output.newline()
		GdUnitEvent.TESTCASE_BEFORE:
			output.append_bbcode("\t[color=#adff2e]%s[/color]:[color=#1f8fff]%-120s[/color]" % [event._suite_name, event._test_name])
		GdUnitEvent.TESTCASE_AFTER:
			var reports := event.reports()
			if reports.size() > 0:
				var report:GdUnitReport = reports[0]
				output.append_bbcode("[color=red][shake]FAILED[/shake][/color]")

				#output.append_bbcode("\t\t line %d %s" % [report._line_number, report._message])
			else:
				output.append_bbcode("[color=green][wave]PASSED[/wave][/color]")

			output.newline()

func _on_client_connected(client_id :int) -> void:
	output.clear()
	output.newline()
	output.append_bbcode("[color=#9887c4]GdUnit Test Client connected with id %d[/color]" % client_id)

func _on_client_disconnected(client_id :int) -> void:
	output.newline()
	output.append_bbcode("[color=#9887c4]GdUnit Test Client disconnected with id %d[/color]" % client_id)

func _on_message(message :String):
	output.newline()
	output.append_bbcode(message)
	output.newline()

tool
class_name SignalHandler
extends Resource

const SINGLETON_NAME := "SignalHandler"

signal client_connected
signal client_disconnected
signal client_terminated
signal send_message
signal test_suite_event
signal test_suite_added


func client_connected(client_id :int) -> void:
	emit_signal("client_connected", client_id)

func register_on_client_connected(target :Object, eventFunc :String) -> void:
	var err = connect("client_connected", target, eventFunc, [], CONNECT_REFERENCE_COUNTED)
	if err != OK:
		push_error("Can't connect signal <client_connected> to %s:%s.\n%s" % [target, eventFunc, GdUnitTools.error_as_string(err)])

func client_disconnected(client_id :int) -> void:
	emit_signal("client_disconnected", client_id)
	
func register_on_client_disconnected(target :Object, eventFunc :String) -> void:
	var err = connect("client_disconnected", target, eventFunc, [], CONNECT_REFERENCE_COUNTED)
	if err != OK:
		push_error("Can't connect signal <client_disconnected> to %s:%s.\n%s" % [target, eventFunc, GdUnitTools.error_as_string(err)])

func send_message(message :String) -> void:
	emit_signal("send_message", message)

func register_on_message(target:Object, eventFunc:String) -> void:
	var err = connect("send_message", target, eventFunc, [], CONNECT_REFERENCE_COUNTED)
	if err != OK:
		push_error("Can't connect signal <send_message> to %s:%s.\n%s" % [target, eventFunc, GdUnitTools.error_as_string(err)])

# add test suite to current running
func send_add_test_suite(test_suite :GdUnitTestSuiteDto) -> void:
	emit_signal("test_suite_added", test_suite)

func register_on_test_suite_added(target :Object, eventFunc :String) -> void:
	var err = connect("test_suite_added", target, eventFunc, [], CONNECT_REFERENCE_COUNTED)
	if err != OK:
		push_error("Can't connect signal <test_suite_added> to %s:%s.\n%s" % [target, eventFunc, GdUnitTools.error_as_string(err)])


# - test suite events
func send_event(event:GdUnitEvent) -> void:
	emit_signal("test_suite_event", event)

func register_on_gdunit_events(target:Object, eventFunc:String) -> void:
	if is_connected("test_suite_event", target, eventFunc):
		return
	var err = connect("test_suite_event", target, eventFunc)
	if err != OK:
		push_error("Can't connect signal <test_suite_added> to %s:%s.\n%s" % [target, eventFunc, GdUnitTools.error_as_string(err)])

func unregister_on_gdunit_events(target:Object, eventFunc:String) -> void:
	if is_connected("test_suite_event", target, eventFunc):
		disconnect("test_suite_event", target, eventFunc)

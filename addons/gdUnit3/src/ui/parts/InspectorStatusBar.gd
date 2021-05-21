tool
extends PanelContainer

onready var _errors = $GridContainer/Errors/value
onready var _failures = $GridContainer/Failures/value

onready var _signal_handler :SignalHandler = GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)

var total_failed := 0
var total_errors := 0

func _ready():
	_signal_handler.register_on_gdunit_events(self, "_on_event")
	_failures.text = "0"
	_errors.text = "0"

func status_changed(errors :int, failed :int):
	total_failed += failed
	total_errors += errors
	_failures.text = str(total_failed)
	_errors.text = str(total_errors)

func _on_event(event :GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.INIT:
			total_failed = 0
			total_errors = 0
			status_changed(0, 0)
		GdUnitEvent.TESTCASE_BEFORE:
			pass
		GdUnitEvent.TESTCASE_AFTER:
			if event.is_error():
				status_changed(event.error_count(), 0)
			else:
				status_changed(0, event.failed_count())
		GdUnitEvent.TESTSUITE_BEFORE:
			pass
		GdUnitEvent.TESTSUITE_AFTER:
			if event.is_error():
				status_changed(event.error_count(), 0)
			else:
				status_changed(0, event.failed_count())

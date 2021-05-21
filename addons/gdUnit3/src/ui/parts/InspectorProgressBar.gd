tool
extends ProgressBar

onready var bar = $"."
onready var status = $Label
onready var style :StyleBoxFlat = bar.get("custom_styles/fg")

onready var _signal_handler :SignalHandler = GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)


func _ready():
	_signal_handler.register_on_gdunit_events(self, "_on_event")
	style.bg_color = Color.darkgreen

func progress_update(value :int, failed :int, max_value :int = -1) -> void:
	if max_value != -1:
		bar.max_value = max_value
	if value == 0:
		bar.value = 0
	bar.value += value
	status.text = str(bar.value) + ":" + str(bar.max_value)
	# if faild change color to red
	if failed > 0:
		var style:StyleBoxFlat  = bar.get("custom_styles/fg")
		style.bg_color = Color.darkred

func _on_event(event :GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.INIT:
			style.bg_color = Color.darkgreen
			progress_update(0, 0, event.total_count())
		GdUnitEvent.TESTCASE_BEFORE:
			pass
		GdUnitEvent.TESTCASE_AFTER:
			progress_update(1, event.is_failed())
		GdUnitEvent.TESTSUITE_BEFORE:
			pass
		GdUnitEvent.TESTSUITE_AFTER:
			pass

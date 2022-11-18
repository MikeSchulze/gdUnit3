# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name NewScriptTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://new_script.gd'

func test_get_() -> void:
	var saveDate = Time.get_datetime_dict_from_system()
	prints(saveDate)

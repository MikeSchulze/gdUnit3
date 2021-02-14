class_name GdUnitInit
extends GdUnitEvent


func _init(total_count:int) -> void:
	_event_type = INIT
	_total_count = total_count

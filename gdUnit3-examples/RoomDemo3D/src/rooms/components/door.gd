#tool
class_name Door
extends Spatial


signal door_opend(door_id)
signal door_closed(door_id)

onready var trigger :Area = $border/trigger
onready var animation :AnimationPlayer = $animate

enum STATE {
	INIT,
	START_OPEN,
	START_CLOSE,
	OPEN,
	CLOSE
}

var _door_state = STATE.INIT

func _ready():
	animation.play("close")

func state() -> int:
	return _door_state

func _on_trigger_body_entered(_body):
	if is_door_closed() and not animation.is_playing():
		animation.play("open")

func _on_trigger_body_exited(_body):
	animation.queue("close")

func is_door_open() -> bool:
	return _door_state == STATE.OPEN

func is_door_closed() -> bool:
	return _door_state == STATE.CLOSE

func _on_animate_animation_finished(anim_name):
	match anim_name:
		"open":
			_door_state = STATE.OPEN
			emit_signal("door_opend", self.get_instance_id())
		"close":
			_door_state = STATE.CLOSE
			emit_signal("door_closed", self.get_instance_id())

func _on_animate_animation_started(anim_name):
	match anim_name:
		"open":
			_door_state = STATE.START_OPEN
		"close":
			_door_state = STATE.START_CLOSE

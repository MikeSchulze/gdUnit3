class_name Spell 
extends Node

signal spell_explode

const SPELL_LIVE_TIME = 1000

var _spell_fired :bool = false
var _spell_live_time :float = 0
var _spell_pos :Vector3 = Vector3.ZERO

# helper counter for testing simulate_frames
var _debug_process_counted := 0

func _ready():
	set_name("Spell")

# only comment in for debugging reasons
#func _notification(what):
#	prints("Spell", GdObjects.notification_as_string(what))

func _process(delta :float):	
	# added pseudo yield to check `simulate_frames` works wih custom yielding
	yield(get_tree(), "idle_frame")
	_spell_live_time += delta * 1000
	if _spell_live_time < SPELL_LIVE_TIME:
		move(delta)
	else:
		explode()

func move(delta :float) -> void:
	#yield(get_tree().create_timer(0.1), "timeout")
	_spell_pos.x += delta 

func explode() -> void:
	emit_signal("spell_explode", self)


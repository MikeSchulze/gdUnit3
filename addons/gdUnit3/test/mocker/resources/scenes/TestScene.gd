extends Control

signal panel_color_change

const COLOR_CYCLE := [Color.royalblue, Color.chartreuse, Color.yellowgreen]

onready var _box1 = $VBoxContainer/PanelContainer/HBoxContainer/Panel1
onready var _box2 = $VBoxContainer/PanelContainer/HBoxContainer/Panel2
onready var _box3 = $VBoxContainer/PanelContainer/HBoxContainer/Panel3

export var _initial_color := Color.red

func _ready():
	#OS.window_maximized = true
	connect("panel_color_change", self, "_on_panel_color_changed")

#func _notification(what):
#	prints("TestScene", GdObjects.notification_as_string(what))

func _on_test_pressed(button_id :int):
	var box :ColorRect
	match button_id:
		1: box = _box1
		2: box = _box2
		3: box = _box3
	emit_signal("panel_color_change", box, Color.red)
	# special case for button 3 we wait 1s to change to gray
	if button_id == 3:
		yield(get_tree().create_timer(1), "timeout")
	emit_signal("panel_color_change", box, Color.gray)

func _on_panel_color_changed(box :ColorRect, color :Color):
	box.color = color

func color_cycle() -> String:
	prints("color_cycle")
	emit_signal("panel_color_change", _box1, Color.red)
	yield(get_tree().create_timer(1), "timeout")
	prints("timer1")
	emit_signal("panel_color_change", _box1, Color.blue)
	yield(get_tree().create_timer(1), "timeout")
	prints("timer2")
	emit_signal("panel_color_change", _box1, Color.green)
	yield(get_tree().create_timer(1), "timeout")
	prints("cycle end")
	return "black"

# used for manuall spy on created spy
func _create_spell() -> Spell:
	return Spell.new()

func create_spell() -> Spell:
	prints("create_spell -------------------")
	var spell := _create_spell()
	spell.connect("spell_explode", self, "_destroy_spell")
	return spell

func _destroy_spell(spell :Spell) -> void:
	prints("_destroy_spell", spell)
	remove_child(spell)
	spell.queue_free()

func _input(event):
	if event.is_action_released("ui_accept"):
		add_child(create_spell())

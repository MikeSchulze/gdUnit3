# Base class for all game menu dialogs
class_name MenuDialog
extends Control

signal close_dialog

func _ready():
	grab_focus()

func _unhandled_input(event :InputEvent):
	if event.is_action_released("ui_cancel"):
		_on_ExitButton_pressed()
		accept_event()
		
	#if event.is_action_released("ui_up") or event.is_action_released("ui_down"):
	#	accept_event()


func _on_ExitButton_pressed():
	emit_signal("close_dialog", get_name())
	queue_free()

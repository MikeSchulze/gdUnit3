tool
extends Control

func _ready():
	print("Scan for project changes ...")
	yield(get_tree().create_timer(2), "timeout")
	get_tree().quit(1)
	prints(" Done")

extends Control

func _ready():
	print("Scan for project changes ...")
	yield(get_tree().create_timer(30), "timeout")
	print("Scan for project changes end")
	get_tree().quit(1)
	prints(" Done")

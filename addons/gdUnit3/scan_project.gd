tool
extends Control


var _counter = 0
var WAIT_TIME_IN_MS = 10.000

func _ready():
	print("Scan for project changes ...")

func _process(delta):
	_counter += delta
	if _counter >= WAIT_TIME_IN_MS:
		print("Scan for project changes done")
		get_tree().quit(1)
	prints("scanning", _counter)
		

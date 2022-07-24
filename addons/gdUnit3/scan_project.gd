tool
extends Control


var _counter = 0
var WAIT_TIME_IN_MS = 5.000

func _ready():
	print("Scan for project changes ...")
	prints(OS.get_time())

func _process(delta):
	_counter += delta
	if _counter >= WAIT_TIME_IN_MS:
		prints("Scan for project changes done")
		get_tree().quit(1)
	prints("scanning", _counter, prints(OS.get_time()))
		

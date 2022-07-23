extends Control


var _counter = 0

func _process(delta):
	print("Scan for project changes ...")
	yield(get_tree().create_timer(1), "timeout")
	_counter += 1
	if _counter == 120:
		print("Scan for project changes done")
		get_tree().quit(1)
		

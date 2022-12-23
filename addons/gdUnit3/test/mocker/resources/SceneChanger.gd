extends Node2D


func _get_tree() -> SceneTree	:
	return get_tree()


func change_scene() -> void:
	_get_tree().change_scene("res://some_scene.tscn")


func _on_ChangeScene_pressed():
	change_scene()

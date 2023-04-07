extends Node2D


onready var og_scale = $Sprite.scale
onready var hover_scale = og_scale * 1.05


func _on_Area2D_mouse_exited() -> void:
	$Sprite.scale = og_scale


func _on_Area2D_mouse_entered():
	$Sprite.scale = hover_scale

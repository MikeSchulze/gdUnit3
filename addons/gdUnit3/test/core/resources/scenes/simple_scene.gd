extends Node2D


func _ready():
	$Sprite.texture = ResourceLoader.load("res://addons/gdUnit3/test/core/resources/scenes/drag_and_drop/icon.png", "", true)

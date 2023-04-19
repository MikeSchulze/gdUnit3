extends Button


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"



func _on_Button_pressed() -> void:
	get_parent().get_parent().get_node("PopupDialog").visible = false

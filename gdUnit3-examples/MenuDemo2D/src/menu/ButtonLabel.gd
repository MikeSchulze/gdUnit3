extends Label


func _on_Label_focus_entered():
	add_color_override("font_color", Color.gold)


func _on_Label_focus_exited():
	add_color_override("font_color", Color.goldenrod)

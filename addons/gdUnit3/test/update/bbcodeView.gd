extends Control

onready var _input :TextEdit = $HSplitContainer/TextEdit
onready var _text :RichTextLabel = $HSplitContainer/RichTextLabel

onready var _update_client :GdUnitUpdateClient = $GdUnitUpdateClient

var _md_reader := GdMarkDownReader.new()

func _ready():
	add_child(_md_reader)
	_md_reader.set_http_client(_update_client)
	
	var source := GdUnitTools.resource_as_string("res://addons/gdUnit3/test/update/resources/markdown.txt")
	_text.bbcode_text = yield(_md_reader.to_bbcode(source), "completed")
	#prints("_ready", _text.bbcode_text )

func set_text(text :String) :
	_text.bbcode_text = text


func _on_TextEdit_text_changed():
	_text.bbcode_text = yield(_md_reader.to_bbcode(_input.get_text()), "completed")
	#prints("_on_TextEdit_text_changed",_text.bbcode_text)


func _on_RichTextLabel_meta_clicked(meta :String):
	var properties = str2var(meta)
	prints("meta_clicked", properties)
	if properties.has("url"):
		OS.shell_open(properties.get("url"))


func _on_RichTextLabel_meta_hover_started(meta :String):
	var properties = str2var(meta)
	prints("hover_started", properties)
	if properties.has("tool_tip"):
		_text.set_tooltip(properties.get("tool_tip"))


func _on_RichTextLabel_meta_hover_ended(meta :String):
	_text.set_tooltip("")

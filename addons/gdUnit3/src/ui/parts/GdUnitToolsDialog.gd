
extends WindowDialog


const EAXAMPLE_URL := ""

onready var _update_client :GdUnitUpdateClient = $GdUnitUpdateClient
onready var _version_label :RichTextLabel = $GridContainer/PanelContainer/Panel/CenterContainer2/version
onready var _btn_install :Button = $GridContainer/PanelContainer/VBoxContainer/btn_install_examples
onready var _progress :ProgressBar = $ProgressBar


func _ready():
	GdUnit3Version.init_version_label(_version_label)
	yield(get_tree(), "idle_frame")
	popup_centered()
	pass # Replace with function body.



func _install_examples() -> void:
	_init_progress(10)
	
	var tmp_path := GdUnitTools.create_temp_dir("download")
	var zip_file := tmp_path + "/examples.zip"
	var response :GdUnitUpdateClient.HttpResponse = yield(_update_client.request_zip_package(EAXAMPLE_URL, zip_file), "completed")
	if response.code() != 200:
		push_warning("Examples cannot be retrieved from GitHub! \n Error code: %d : %s" % [response.code(), response.response()])
		#update_progress("Update failed! Try it later again.")
		yield(get_tree().create_timer(3), "timeout")
		stop_progress()
		return
	
	# extract zip to tmp
	var source := ProjectSettings.globalize_path(zip_file)
	var dest := ProjectSettings.globalize_path(tmp_path)
	
	update_progress("extracting zip '%s' to '%s'" % [source, dest])
	var result := _extract_package(source, dest)
	if result.is_error():
		update_progress("Update failed! %s" % result.error_message())
		yield(get_tree().create_timer(3), "timeout")
		stop_progress()
		enable_gdUnit()
		return
	
	
	stop_progress()


func parse_content(content :Array) -> Dictionary:
	return {}
	
	






func _on_btn_report_bug_pressed():
	OS.shell_open("https://github.com/MikeSchulze/gdUnit3/issues/new?assignees=MikeSchulze&labels=bug&template=bug_report.md&title=")

func _on_btn_request_feature_pressed():
	OS.shell_open("https://github.com/MikeSchulze/gdUnit3/issues/new?assignees=MikeSchulze&labels=enhancement&template=feature_request.md&title=")


func _init_progress(max_value : int) -> void:
	_progress.visible = true
	_progress.max_value = max_value
	_progress.value = 0

func _progress() -> void:
	_progress.value += 1

func stop_progress() -> void:
	_progress.visible = false
	
func update_progress(message :String) -> void:
	#_info_content.text = message
	_progress.value += 1
	prints("Update ..", message)


func _on_btn_install_examples_pressed():
	_btn_install.disabled = true
	
	_install_examples()
	#yield(get_tree().create_timer(5), "timeout")
	
	_btn_install.disabled = false
	

func _on_btn_close_pressed():
	hide()



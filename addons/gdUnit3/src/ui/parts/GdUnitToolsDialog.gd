tool
extends WindowDialog


const EAXAMPLE_URL := "https://github.com/MikeSchulze/gdUnit3-examples/archive/refs/heads/master.zip"

onready var _update_client :GdUnitUpdateClient = $GdUnitUpdateClient
onready var _version_label :RichTextLabel = $MarginContainer/GridContainer/PanelContainer/Panel/CenterContainer2/version
onready var _btn_install :Button = $MarginContainer/GridContainer/PanelContainer/VBoxContainer/btn_install_examples
onready var _progress :ProgressBar = $MarginContainer2/HBoxContainer/ProgressBar
onready var _progress_text :Label = $MarginContainer2/HBoxContainer/ProgressBar/Label


func _ready():
	GdUnit3Version.init_version_label(_version_label)
	yield(get_tree(), "idle_frame")
	#popup_centered()

func _install_examples() -> void:
	_init_progress(5)
	
	update_progress("Downloading examples")
	yield(get_tree(), "idle_frame")
	var tmp_path := GdUnitTools.create_temp_dir("download")
	var zip_file := tmp_path + "/examples.zip"
	var response :GdUnitUpdateClient.HttpResponse = yield(_update_client.request_zip_package(EAXAMPLE_URL, zip_file), "completed")
	if response.code() != 200:
		push_warning("Examples cannot be retrieved from GitHub! \n Error code: %d : %s" % [response.code(), response.response()])
		update_progress("Install examples failed! Try it later again.")
		yield(get_tree().create_timer(3), "timeout")
		stop_progress()
		return
	
	# extract zip to tmp
	var source := ProjectSettings.globalize_path(zip_file)
	var dest := ProjectSettings.globalize_path(tmp_path)
	update_progress("Extracting zip '%s' to '%s'" % [source, dest])
	yield(get_tree(), "idle_frame")
	
	var result := GdUnitTools.extract_package(source, dest)
	if result.is_error():
		update_progress("Update failed! %s" % result.error_message())
		yield(get_tree().create_timer(3), "timeout")
		stop_progress()
		return
	
	var source_dir = tmp_path + "/gdUnit3-examples-master"
	update_progress("Install examples into project")
	yield(get_tree(), "idle_frame")
	GdUnitTools.copy_directory(source_dir, "res://gdUnit3-examples/", true)
	
	update_progress("Refresh project")
	yield(get_tree(), "idle_frame")
	yield(rescan(true), "completed")
	update_progress("Examples successfully installed")
	yield(get_tree().create_timer(3), "timeout")
	stop_progress()

func rescan(update_scripts :bool = false) -> void:
	var plugin := EditorPlugin.new()
	var fs := plugin.get_editor_interface().get_resource_filesystem()
	fs.scan_sources()
	while fs.is_scanning():
		yield(get_tree().create_timer(1), "timeout")
	if update_scripts:
		plugin.get_editor_interface().get_resource_filesystem().update_script_classes()
	plugin.free()

func _on_btn_report_bug_pressed():
	OS.shell_open("https://github.com/MikeSchulze/gdUnit3/issues/new?assignees=MikeSchulze&labels=bug&template=bug_report.md&title=")

func _on_btn_request_feature_pressed():
	OS.shell_open("https://github.com/MikeSchulze/gdUnit3/issues/new?assignees=MikeSchulze&labels=enhancement&template=feature_request.md&title=")

func _on_btn_install_examples_pressed():
	_btn_install.disabled = true
	yield(_install_examples(), "completed")
	_btn_install.disabled = false

func _on_btn_close_pressed():
	hide()

func _init_progress(max_value : int) -> void:
	_progress.visible = true
	_progress.max_value = max_value
	_progress.value = 0

func _progress() -> void:
	_progress.value += 1

func stop_progress() -> void:
	_progress.visible = false
	
func update_progress(message :String) -> void:
	_progress_text.text = message
	_progress.value += 1
	prints(message)

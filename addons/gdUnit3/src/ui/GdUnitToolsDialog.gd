tool
extends WindowDialog


const EAXAMPLE_URL := "https://github.com/MikeSchulze/gdUnit3-examples/archive/refs/heads/master.zip"

onready var _update_client :GdUnitUpdateClient = $GdUnitUpdateClient
onready var _version_label :RichTextLabel = $v/MarginContainer/GridContainer/PanelContainer/Panel/CenterContainer2/version
onready var _btn_install :Button = $v/MarginContainer/GridContainer/PanelContainer/VBoxContainer/btn_install_examples
onready var _progress :ProgressBar = $v/MarginContainer2/HBoxContainer/ProgressBar
onready var _progress_text :Label = $v/MarginContainer2/HBoxContainer/ProgressBar/Label

onready var _properties_template :Node = $property_template
onready var _properties_common :Node = $v/MarginContainer/GridContainer/Properties/Common/VBoxContainer
onready var _properties_report :Node = $v/MarginContainer/GridContainer/Properties/Report/VBoxContainer

func _ready():
	GdUnit3Version.init_version_label(_version_label)
	setup_common_properties(_properties_common, GdUnitSettings.COMMON_SETTINGS)
	setup_common_properties(_properties_report, GdUnitSettings.REPORT_SETTINGS)
	yield(get_tree(), "idle_frame")
	popup_centered_ratio(.75)

func _sort_by_key(left :GdUnitProperty, right :GdUnitProperty) -> bool:
	return left.name() < right.name()

func setup_common_properties(properties_parent :Node, property_category) -> void:
	var category_properties := GdUnitSettings.list_settings(property_category)
	# sort by key
	category_properties.sort_custom(self, "_sort_by_key")
	var t := Theme.new()
	t.set_constant("hseparation", "GridContainer", 12)
	
	var last_category := "!"
	for p in category_properties:
		var grid := GridContainer.new()
		grid.columns = 4
		grid.theme = t
		var property : GdUnitProperty = p
		var current_category = property.category()
		if current_category != last_category:
			var sub_category :Node = _properties_template.get_child(3).duplicate()
			sub_category.get_child(0).text = current_category.capitalize()
			properties_parent.add_child(sub_category)
			last_category = current_category
		# property name
		var label :Label = _properties_template.get_child(0).duplicate()
		label.text = _to_human_readable(property.name())
		label.set_custom_minimum_size(Vector2(300, 0))
		grid.add_child(label)
		
		# property reset btn
		var reset_btn :ToolButton = _properties_template.get_child(1).duplicate()
		reset_btn.icon = _get_btn_icon("Reload")
		reset_btn.disabled = property.value() == property.default()
		grid.add_child(reset_btn)
		
		# property type specific input element
		var input :Node = _create_input_element(property, reset_btn)
		grid.add_child(input)
		reset_btn.connect("pressed", self, "_on_btn_property_reset_pressed", [property, input, reset_btn])
		# property help text
		var info :Node = _properties_template.get_child(2).duplicate()
		info.text = property.help()
		grid.add_child(info)
		properties_parent.add_child(grid)

func _create_input_element(property: GdUnitProperty, reset_btn :ToolButton) -> Node:
	if property.is_selectable_value():
		var options := OptionButton.new()
		var values_set := Array(property.value_set())
		for value in values_set:
			options.add_item(value)
		options.connect("item_selected", self, "_on_option_selected", [property, reset_btn])
		options.select(property.value())
		options.set_custom_minimum_size(Vector2(120, 0))
		return options
	if property.type() == TYPE_BOOL: 
		var check_btn := CheckButton.new()
		check_btn.connect("toggled", self, "_on_property_text_changed", [property, reset_btn])
		check_btn.pressed = property.value()
		check_btn.set_custom_minimum_size(Vector2(120, 0))
		return check_btn
	if property.type() in [TYPE_INT, TYPE_STRING]:
			var input := LineEdit.new()
			input.connect("text_changed", self, "_on_property_text_changed", [property, reset_btn])
			input.text = str(property.value())
			input.set_align(HALIGN_RIGHT)
			input.set_custom_minimum_size(Vector2(120, 0))
			return input 
	return Control.new()

func _to_human_readable(value :String) -> String:
	return value.split("/")[-1].capitalize()

func _get_btn_icon(name :String) -> Texture:
	var editor :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	if editor:
		var editiorTheme := editor.get_editor_interface().get_base_control().theme
		return editiorTheme.get_icon(name, "EditorIcons")
	return null

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
		update_progress("Install examples failed! %s" % result.error_message())
		yield(get_tree().create_timer(3), "timeout")
		stop_progress()
		return
	
	var source_dir = tmp_path + "/gdUnit3-examples-master"
	update_progress("Install examples into project")
	yield(get_tree(), "idle_frame")
	GdUnitTools.copy_directory(source_dir, "res://gdUnit3-examples/", true)
	
	update_progress("Refresh project")
	yield(rescan(true), "completed")
	update_progress("Examples successfully installed")
	yield(get_tree().create_timer(3), "timeout")
	stop_progress()

func rescan(update_scripts :bool = false) -> void:
	yield(get_tree(), "idle_frame")
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

func _on_btn_property_reset_pressed(property: GdUnitProperty, input :Node, reset_btn :ToolButton):
	if input is CheckButton:
		input.pressed = property.default()
	elif input is LineEdit:
		input.text = str(property.default())
		# we have to update manually for text input fields because of no change event is emited
		_on_property_text_changed(property.default(), property, reset_btn)
	elif input is OptionButton:
		input.select(0)
		_on_option_selected(0, property, reset_btn)

func _on_property_text_changed(new_value, property: GdUnitProperty, reset_btn :ToolButton):
	property.set_value(new_value)
	reset_btn.disabled = property.value() == property.default()
	GdUnitSettings.update_property(property)

func _on_option_selected(index :int, property: GdUnitProperty, reset_btn :ToolButton):
	property.set_value(index)
	reset_btn.disabled = property.value() == property.default()
	GdUnitSettings.update_property(property)

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

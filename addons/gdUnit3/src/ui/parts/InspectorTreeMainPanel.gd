tool
extends VSplitContainer

signal run_testcase
signal run_testsuite


onready var _tree :Tree = $Panel/Tree
onready var _report_list :Node = $report/ScrollContainer/list
onready var _report_template :RichTextLabel = $report/report_template

onready var _context_menu :PopupPanel = $contextMenu
onready var _context_menu_run := $contextMenu/items/run
onready var _context_menu_debug := $contextMenu/items/debug

# tree icons
onready var ICON_SPINNER = load("res://addons/gdUnit3/src/ui/assets/spinner.tres")
onready var ICON_TEST_DEFAULT = load_resized_texture("res://addons/gdUnit3/src/ui/assets/TestCase.svg")
onready var ICON_TEST_SUCCESS = load_resized_texture("res://addons/gdUnit3/src/ui/assets/TestCaseSuccess.svg")
onready var ICON_TEST_FAILED = load_resized_texture("res://addons/gdUnit3/src/ui/assets/TestCaseFailed.svg")
onready var ICON_TEST_ERROR = load_resized_texture("res://addons/gdUnit3/src/ui/assets/TestCaseError.svg")

onready var ICON_TEST_SUCCESS_ORPHAN = load("res://addons/gdUnit3/src/ui/assets/TestCase_success_orphan.tres")
onready var ICON_TEST_FAILED_ORPHAN = load("res://addons/gdUnit3/src/ui/assets/TestCase_failed_orphan.tres")
onready var ICON_TEST_ERRORS_ORPHAN = load("res://addons/gdUnit3/src/ui/assets/TestCase_error_orphan.tres")

onready var _signal_handler :SignalHandler = GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)

enum GdUnitType {
	TEST_SUITE,
	TEST_CASE
}

enum STATE {
	INITIAL,
	RUNNING,
	SUCCESS,
	WARNING,
	FAILED,
	ERROR,
	ABORDED
}
const META_GDUNIT_NAME := "gdUnit_name"
const META_GDUNIT_STATE := "gdUnit_state"
const META_GDUNIT_TYPE := "gdUnit_type"
const META_GDUNIT_SUITE_TOTAL_TESTS := "gdUnit_suite_total_tests"
const META_GDUNIT_SUITE_SUCCESS_TESTS := "gdUnit_suite_success_tests"
const META_GDUNIT_REPORT := "gdUnit_report"
const META_GDUNIT_ORPHAN := "gdUnit_orphan"
const META_RESOURCE_PATH := "resource_path"
const META_LINE_NUMBER := "line_number"

var _editor :EditorPlugin
var _tree_root :TreeItem
var _current_failures := Array()
var _item_hash := Dictionary()


func _build_cache_key(resource_path :String, test_name :String) -> Array:
	return [resource_path, test_name]

func get_tree_item(event :GdUnitEvent) -> TreeItem:
	var key := _build_cache_key(event.resource_path(), event.test_name())
	return _item_hash.get(key, null)

func add_tree_item_to_cache(resource_path :String, test_name :String, item :TreeItem) -> void:
	var key := _build_cache_key(resource_path, test_name)
	_item_hash[key] = item

func clear_tree_item_cache() -> void:
	_item_hash.clear()

static func _find_item(parent :TreeItem, resource_path :String, test_case :String = "") -> TreeItem:
	var item = _find_by_resource_path(parent, resource_path)
	if not item:
		return null
	if test_case.empty():
		return item
	return _find_by_name(item, test_case)

static func _find_by_resource_path(parent :TreeItem, resource_path :String) -> TreeItem:
	var item :=  parent.get_children()
	while item != null:
		if item.get_meta(META_RESOURCE_PATH) == resource_path:
			return item
		item = item.get_next()
	return null

static func _find_by_name(parent :TreeItem, name :String) -> TreeItem:
	var item :=  parent.get_children()
	while item != null:
		if item.get_meta(META_GDUNIT_NAME) == name:
			return item
		item = item.get_next()
	return null

static func is_state_running(item :TreeItem) -> bool:
	return item.has_meta(META_GDUNIT_STATE) and item.get_meta(META_GDUNIT_STATE) == STATE.RUNNING

static func is_state_success(item :TreeItem) -> bool:
	return item.has_meta(META_GDUNIT_STATE) and item.get_meta(META_GDUNIT_STATE) == STATE.SUCCESS

static func is_state_warning(item :TreeItem) -> bool:
	return item.has_meta(META_GDUNIT_STATE) and item.get_meta(META_GDUNIT_STATE) == STATE.WARNING

static func is_state_failed(item :TreeItem) -> bool:
	return item.has_meta(META_GDUNIT_STATE) and item.get_meta(META_GDUNIT_STATE) == STATE.FAILED

static func is_state_error(item :TreeItem) -> bool:
	return item.has_meta(META_GDUNIT_STATE) and (item.get_meta(META_GDUNIT_STATE) == STATE.ERROR or item.get_meta(META_GDUNIT_STATE) == STATE.ABORDED)

static func is_item_state_orphan(item :TreeItem) -> bool:
	if item.has_meta(META_GDUNIT_ORPHAN):
		return item.get_meta(META_GDUNIT_ORPHAN) as bool
	return false

func _ready():
	init_tree()
	if Engine.editor_hint:
		_editor = Engine.get_meta("GdUnitEditorPlugin")
	_signal_handler.register_on_test_suite_added(self, "_on_test_suite_added")
	_signal_handler.register_on_gdunit_events(self, "_on_event")

static func load_resized_texture(path :String, width :int = 16, height :int = 16) -> Texture:
	var texture :Texture = load(path)
	var image = texture.get_data()
	if width > 0 && height > 0:
		image.resize(width, height)
	var itex := ImageTexture.new()
	itex.create_from_image(image)
	return itex

func init_tree() -> void:
	cleanup_tree()
	_tree.set_hide_root(true)
	_tree.ensure_cursor_is_visible()
	_tree.allow_rmb_select = true
	_tree_root = _tree.create_item()

func cleanup_tree() -> void:
	clear_failures()
	clear_tree_item_cache()
	if not _tree_root:
		return
	var parent := _tree_root.get_children()
	while parent != null:
		var item :=  parent.get_children()
		while item != null:
			var next_item = item.get_next()
			item.free()
			item = next_item
		var next_parent = parent.get_next()
		parent.free()
		parent = next_parent
	_tree_root.free()
	_tree.clear()
	# clear old reports
	for child in _report_list.get_children():
		_report_list.remove_child(child)

func select_item(item :TreeItem) -> void:
	if not item.is_selected(0):
		item.select(0)
		_tree.ensure_cursor_is_visible()

func set_state_running(item :TreeItem) -> void:
	item.set_custom_color(0, Color.darkgreen)
	item.set_icon(0, ICON_SPINNER)
	item.set_tooltip(0, "")
	item.set_meta(META_GDUNIT_STATE, STATE.RUNNING)
	item.remove_meta(META_GDUNIT_REPORT)
	item.remove_meta(META_GDUNIT_ORPHAN)
	item.collapsed = false
	# force scrolling to current test case
	select_item(item)

func set_state_succeded(item :TreeItem) -> void:
	item.set_meta(META_GDUNIT_STATE, STATE.SUCCESS)
	item.set_custom_color(0, Color.green)
	item.set_icon(0, ICON_TEST_SUCCESS)
	item.collapsed = true

func set_state_warnings(item :TreeItem) -> void:
	item.set_meta(META_GDUNIT_STATE, STATE.WARNING)
	item.set_custom_color(0, Color.yellow)
	item.set_icon(0, ICON_TEST_SUCCESS)
	item.collapsed = false

func set_state_failed(item :TreeItem) -> void:
	item.set_meta(META_GDUNIT_STATE, STATE.FAILED)
	item.set_custom_color(0, Color.lightblue)
	item.set_icon(0, ICON_TEST_FAILED)
	item.collapsed = false

func set_state_error(item :TreeItem) -> void:
	item.set_meta(META_GDUNIT_STATE, STATE.ERROR)
	item.set_custom_color(0, Color.darkred)
	item.set_suffix(0, "timeout! " + item.get_suffix(0))
	item.set_icon(0, ICON_TEST_ERROR)
	item.collapsed = false

func set_state_aborted(item :TreeItem) -> void:
	item.set_meta(META_GDUNIT_STATE, STATE.ABORDED)
	item.set_icon(0, ICON_TEST_ERROR)
	item.set_custom_color(0, Color.darkred)
	item.set_suffix(0, "(aborted)")
	item.clear_custom_bg_color(0)
	item.collapsed = false

func set_elapsed_time(item :TreeItem, time :int) -> void:
	item.set_suffix(0, "(%s)" % LocalTime.elapsed(time))

func set_state_orphan(item :TreeItem, event: GdUnitEvent) -> void:
	var orphan_count = event.statistic(GdUnitEvent.ORPHAN_NODES)
	if orphan_count == 0:
		return
	if item.has_meta(META_GDUNIT_ORPHAN):
		orphan_count += item.get_meta(META_GDUNIT_ORPHAN)
	item.set_meta(META_GDUNIT_ORPHAN, orphan_count)
	item.set_custom_color(0, Color.yellow)
	item.set_tooltip(0, "Total <%d> orphan nodes detected." % orphan_count)
	if is_state_warning(item):
		item.set_icon(0, ICON_TEST_SUCCESS_ORPHAN)
	if is_state_failed(item):
		item.set_icon(0, ICON_TEST_FAILED_ORPHAN)
	if is_state_error(item):
		item.set_icon(0, ICON_TEST_ERRORS_ORPHAN)

func update_state(item: TreeItem, event :GdUnitEvent) -> void:
	if is_state_running(item) and event.is_success():
		set_state_succeded(item)
	else:
		if event.is_warning():
			set_state_warnings(item)
		if event.is_failed():
			set_state_failed(item)
		if event.is_error():
			set_state_error(item)
		for report in event.reports():
			add_report(item, report)
	set_state_orphan(item, event)

func add_report(item :TreeItem, report: GdUnitReport) -> void:
	var reports = []
	if item.has_meta(META_GDUNIT_REPORT):
		reports = item.get_meta(META_GDUNIT_REPORT)
	reports.append(report)
	item.set_meta(META_GDUNIT_REPORT, reports)

func abort_running() -> void:
	var parent := _tree_root.get_children()
	while parent != null:
		if is_state_running(parent):
			set_state_aborted(parent)
			var item :=  parent.get_children()
			while item != null:
				if is_state_running(item):
					set_state_aborted(item)
				item = item.get_next()
		parent = parent.get_next()

func select_first_failure() -> void:
	if not _current_failures.empty():
		select_item(_current_failures[0])

func select_last_failure() -> void:
	if not _current_failures.empty():
		select_item(_current_failures[-1])

func clear_failures() -> void:
	_current_failures.clear()

func collect_failures_and_errors() -> Array:
	clear_failures()
	var parent := _tree_root.get_children()
	while parent != null:
		if is_state_failed(parent) or is_state_error(parent):
			var item :=  parent.get_children()
			while item != null:
				if is_state_failed(item) or is_state_error(item):
					_current_failures.append(item)
				item = item.get_next()
		parent = parent.get_next()
	return _current_failures

func select_next_failure() -> void:
	var current_selected := _tree.get_selected()
	if current_selected == null:
		select_first_failure()
		return
	if _current_failures.empty():
		return
	var index := _current_failures.find(current_selected)
	if index == -1 or index == _current_failures.size()-1:
		select_item(_current_failures[0])
	else:
		select_item(_current_failures[index+1])

func select_previous_failure() -> void:
	var current_selected := _tree.get_selected()
	if current_selected == null:
		select_last_failure()
		return
	if _current_failures.empty():
		return
	var index := _current_failures.find(current_selected)
	if index == -1 or index == 0:
		select_item(_current_failures[_current_failures.size()-1])
	else:
		select_item(_current_failures[index-1])

func select_first_orphan() -> void:
	var parent := _tree_root.get_children()
	while parent != null:
		if not is_state_success(parent):
			var item :=  parent.get_children()
			while item != null:
				if is_item_state_orphan(item):
					parent.set_collapsed(false)
					select_item(item)
					return
				item = item.get_next()
		parent = parent.get_next()

func show_failed_report(selected_item :TreeItem) -> void:
	# clear old reports
	for child in _report_list.get_children():
		_report_list.remove_child(child)

	if selected_item == null or not selected_item.has_meta(META_GDUNIT_REPORT):
		return
	# add new reports
	for r in selected_item.get_meta(META_GDUNIT_REPORT):
		var report := r as GdUnitReport
		var reportNode = _report_template.clone()
		reportNode.visible = true
		reportNode.set_bbcode(report.to_string())
		_report_list.add_child(reportNode)

func update_test_suite(event :GdUnitEvent) -> void:
	var item := _find_by_resource_path(_tree_root, event.resource_path())
	if not item:
		push_error("Internal Error: Can't find test suite %s" % event.suite_name())
		return
	if event.type() == GdUnitEvent.TESTSUITE_BEFORE:
		set_state_running(item)
		return
	if event.type() == GdUnitEvent.TESTSUITE_AFTER:
		set_elapsed_time(item, event.elapsed_time())
	update_state(item, event)

func update_test_case(event :GdUnitEvent) -> void:
	var item := get_tree_item(event)
	if not item:
		push_error("Internal Error: Can't find test case %s:%s" % [event.suite_name(), event.test_name()])
		return
	if event.type() == GdUnitEvent.TESTCASE_BEFORE:
		set_state_running(item)
		return
	if event.type() == GdUnitEvent.TESTCASE_AFTER:
		set_elapsed_time(item, event.elapsed_time())
		
		if event.is_success():
			_update_test_suite_with_successful_case(event.resource_path())
	update_state(item, event)

func add_test_suite(test_suite :GdUnitTestSuiteDto) -> void:
	var item := _tree.create_item(_tree_root)
	var suite_name := test_suite.name()
	var test_count := test_suite.test_case_count()
	
	item.set_icon(0, ICON_TEST_DEFAULT)
	item.set_meta(META_GDUNIT_STATE, STATE.INITIAL)
	item.set_meta(META_GDUNIT_NAME, suite_name)
	item.set_meta(META_GDUNIT_TYPE, GdUnitType.TEST_SUITE)
	item.set_meta(META_GDUNIT_SUITE_TOTAL_TESTS, test_count)
	item.set_meta(META_GDUNIT_SUITE_SUCCESS_TESTS, 0)
	item.set_meta(META_RESOURCE_PATH, test_suite.path())
	item.set_meta(META_LINE_NUMBER, 1)
	item.collapsed = true
	
	_update_test_suite_item_text(item)
	
	for test_case in test_suite.test_cases():
		add_test_case(item, test_case)

func _update_test_suite_item_text(item: TreeItem):
	item.set_text(0, "(%s/%s) %s" % [
		item.get_meta(META_GDUNIT_SUITE_SUCCESS_TESTS), 
		item.get_meta(META_GDUNIT_SUITE_TOTAL_TESTS),
		item.get_meta(META_GDUNIT_NAME)])

func _update_test_suite_with_successful_case(resource_path: String):
	var suite_item := _find_by_resource_path(_tree_root, resource_path)
	if suite_item:
		var successes: int = suite_item.get_meta(META_GDUNIT_SUITE_SUCCESS_TESTS)
		suite_item.set_meta(META_GDUNIT_SUITE_SUCCESS_TESTS, successes + 1)
		_update_test_suite_item_text(suite_item)
	else:
		push_error("Internal Error: Can't find test suite %s" % resource_path)

func add_test_case(parent :TreeItem, test_case :GdUnitTestCaseDto) -> void:
	var item := _tree.create_item(parent)
	var test_name := test_case.name()
	
	item.set_text(0, test_name)
	item.set_icon(0, ICON_TEST_DEFAULT)
	item.set_meta(META_GDUNIT_STATE, STATE.INITIAL)
	item.set_meta(META_GDUNIT_NAME, test_name)
	item.set_meta(META_GDUNIT_TYPE, GdUnitType.TEST_CASE)
	item.set_meta(META_RESOURCE_PATH, parent.get_meta(META_RESOURCE_PATH))
	item.set_meta(META_LINE_NUMBER, test_case.line_number())
	add_tree_item_to_cache(parent.get_meta(META_RESOURCE_PATH), test_name, item)

################################################################################
# Tree signal receiver
################################################################################
func _on_Tree_item_rmb_selected(position :Vector2) -> void:
	_context_menu.rect_position = position + _tree.get_global_position()
	_context_menu.popup()

func _on_run_pressed(run_debug :bool) -> void:
	_context_menu.hide()
	var item := _tree.get_selected()
	if item.get_meta(META_GDUNIT_TYPE) == GdUnitType.TEST_SUITE:
		var resource_path = item.get_meta(META_RESOURCE_PATH)
		emit_signal("run_testsuite", [resource_path], run_debug)
		return
	var parent = item.get_parent()
	var test_suite_resource_path = parent.get_meta(META_RESOURCE_PATH)
	var test_case = item.get_text(0)
	emit_signal("run_testcase", test_suite_resource_path, test_case, run_debug)

func _on_Tree_item_selected() -> void:
	# only show report on manual item selection
	# we need to check the run mode here otherwise it will be called every selection
	if not _context_menu_run.disabled:
		show_failed_report(_tree.get_selected())

# Opens the test suite
func _on_Tree_item_activated() -> void:
	var selected_item := _tree.get_selected()
	var resource_path = selected_item.get_meta(META_RESOURCE_PATH)
	var line_number = selected_item.get_meta(META_LINE_NUMBER)
	var resource = load(resource_path)

	if selected_item.has_meta(META_GDUNIT_REPORT):
		var reports :Array = selected_item.get_meta(META_GDUNIT_REPORT)
		var report_line_number = reports[0].line_number()
		# if number -1 we use original stored line number of the test case
		# in non debug mode the line number is not available
		if report_line_number != -1:
			line_number = report_line_number

	var editor_interface := _editor.get_editor_interface()
	editor_interface.get_file_system_dock().navigate_to_path(resource_path)
	editor_interface.edit_resource(resource)
	editor_interface.get_script_editor().goto_line(line_number-1)

func _on_Tree_item_double_clicked() -> void:
	_on_Tree_item_activated()

################################################################################
# external signal receiver
################################################################################
func _on_GdUnit_gdunit_runner_start():
	_context_menu_run.disabled = true
	_context_menu_debug.disabled = true
	clear_failures()

func _on_GdUnit_gdunit_runner_stop(client_id :int):
	_context_menu_run.disabled = false
	_context_menu_debug.disabled = false
	abort_running()
	collect_failures_and_errors()
	select_first_failure()

func _on_test_suite_added(test_suite :GdUnitTestSuiteDto) -> void:
	add_test_suite(test_suite)

func _on_event(event:GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.INIT:
			init_tree()
		GdUnitEvent.STOP:
			select_first_failure()
			show_failed_report(_tree.get_selected())
		GdUnitEvent.TESTCASE_BEFORE:
			update_test_case(event)
		GdUnitEvent.TESTCASE_AFTER:
			update_test_case(event)
		GdUnitEvent.TESTSUITE_BEFORE:
			update_test_suite(event)
		GdUnitEvent.TESTSUITE_AFTER:
			update_test_suite(event)

func _on_Monitor_jump_to_orphan_nodes():
	select_first_orphan()

func _on_StatusBar_failure_next():
	select_next_failure()

func _on_StatusBar_failure_prevous():
	select_previous_failure()

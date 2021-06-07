# GdUnit generated TestSuite
class_name InspectorTreeMainPanelTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/ui/parts/InspectorTreeMainPanel.gd'

var _inspector

func before_test():
	_inspector = load("res://addons/gdUnit3/src/ui/parts/InspectorTreePanel.tscn").instance()
	add_child(_inspector)
	_inspector.init_tree()
	
	# load a testsuite 
	for test_suite in setup_test_env():
		_inspector.add_test_suite(test_suite)
	# verify no failures are exists
	assert_array(_inspector.collect_failures_and_errors()).is_empty()

func after_test():
	_inspector.cleanup_tree()
	remove_child(_inspector)
	_inspector.free()

func setup_test_env() -> Array:
	var tsA := GdUnitTestSuite.new()
	tsA.set_name("TestSuiteA")
	tsA.add_child(_TestCase.new().configure("test_aa", 10, "/foo/TestSuiteA.gd"))
	tsA.add_child(_TestCase.new().configure("test_ab", 20, "/foo/TestSuiteA.gd"))
	tsA.add_child(_TestCase.new().configure("test_ac", 30, "/foo/TestSuiteA.gd"))
	tsA.add_child(_TestCase.new().configure("test_ad", 40, "/foo/TestSuiteA.gd"))
	tsA.add_child(_TestCase.new().configure("test_ae", 50, "/foo/TestSuiteA.gd"))
	
	var tsB := GdUnitTestSuite.new()
	tsB.set_name("TestSuiteB")
	tsB.add_child(_TestCase.new().configure("test_ba", 10, "/foo/TestSuiteA.gd"))
	tsB.add_child(_TestCase.new().configure("test_bb", 20, "/foo/TestSuiteA.gd"))
	tsB.add_child(_TestCase.new().configure("test_bc", 30, "/foo/TestSuiteA.gd"))
	tsB.add_child(_TestCase.new().configure("test_bd", 40, "/foo/TestSuiteA.gd"))
	tsB.add_child(_TestCase.new().configure("test_be", 50, "/foo/TestSuiteA.gd"))
	
	var tsC := GdUnitTestSuite.new()
	tsC.set_name("TestSuiteC")
	tsC.add_child(_TestCase.new().configure("test_ca", 10, "/foo/TestSuiteA.gd"))
	tsC.add_child(_TestCase.new().configure("test_cb", 20, "/foo/TestSuiteA.gd"))
	tsC.add_child(_TestCase.new().configure("test_cc", 30, "/foo/TestSuiteA.gd"))
	tsC.add_child(_TestCase.new().configure("test_cd", 40, "/foo/TestSuiteA.gd"))
	tsC.add_child(_TestCase.new().configure("test_ce", 50, "/foo/TestSuiteA.gd"))
	return Array([tsA, tsB, tsC])

func mark_as_failure(inspector, test_cases :Array) -> void:
	var tree_root :TreeItem = inspector._tree_root
	assert_object(tree_root).is_not_null()
	# mark all test as failed
	var parent := tree_root.get_children()
	while parent != null:
		inspector.set_state_succeded(parent)
		var item :=  parent.get_children()
		while item != null:
			if test_cases.has(item.get_text(0)):
				inspector.set_state_failed(parent)
				inspector.set_state_failed(item)
			else:
				inspector.set_state_succeded(item)
			item = item.get_next()
		parent = parent.get_next()

func test_collect_failures_and_errors() -> void:
	# mark some test as failed
	mark_as_failure(_inspector, ["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"])
	
	assert_array(_inspector.collect_failures_and_errors())\
		.extract("get_text", [0])\
		.contains_exactly(["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"])

func test_select_first_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()
	
	# we have no failures or errors
	_inspector.collect_failures_and_errors()
	_inspector.select_first_failure()
	assert_object(_inspector._tree.get_selected()).is_null()
	
	# add failures
	mark_as_failure(_inspector, ["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"])
	_inspector.collect_failures_and_errors()
	# select first failure
	_inspector.select_first_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")

func test_select_last_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()
	
	# we have no failures or errors
	_inspector.collect_failures_and_errors()
	_inspector.select_last_failure()
	assert_object(_inspector._tree.get_selected()).is_null()
	
	# add failures
	mark_as_failure(_inspector, ["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"])
	_inspector.collect_failures_and_errors()
	# select last failure
	_inspector.select_last_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")


func test_clear_failures() -> void:
	assert_array(_inspector._current_failures).is_empty()
	
	mark_as_failure(_inspector, ["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"])
	_inspector.collect_failures_and_errors()
	assert_array(_inspector._current_failures).is_not_empty()
	
	# clear it
	_inspector.clear_failures()
	assert_array(_inspector._current_failures).is_empty()

func test_select_next_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()
	
	# first time select next but no failure exists
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected()).is_null()
	
	# add failures
	mark_as_failure(_inspector, ["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"])
	_inspector.collect_failures_and_errors()
	
	# first time select next than select first failure
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ad")
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cb")
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	# if current last failure selected than select first as next
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")
	_inspector.select_next_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ad")

func test_select_previous_failure() -> void:
	# test initial nothing is selected
	assert_object(_inspector._tree.get_selected()).is_null()
	
	# first time select previous but no failure exists
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected()).is_null()
	
	# add failures
	mark_as_failure(_inspector, ["test_aa", "test_ad", "test_cb", "test_cc", "test_ce"])
	_inspector.collect_failures_and_errors()
	
	# first time select previous than select last failure
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cb")
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ad")
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_aa")
	# if current first failure selected than select last as next
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_ce")
	_inspector.select_previous_failure()
	assert_str(_inspector._tree.get_selected().get_text(0)).is_equal("test_cc")

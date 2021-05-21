class_name GdUnitSpyTest
extends GdUnitTestSuite

# small helper to verify last assert error
func assert_last_error(expected :String):
	var gd_assert := GdUnitAssertImpl.new(self, "")
	if Engine.has_meta(GdAssertReports.LAST_ERROR):
		gd_assert._current_error_message = Engine.get_meta(GdAssertReports.LAST_ERROR)
	gd_assert.has_error_message(expected)

func test_cant_spy_is_not_a_instance():
	# returns null because spy needs an 'real' instance to by spy on
	var spy_node = spy(Node)
	assert_object(spy_node).is_null()

func test_spy_on_Node():
	var instance :Node = auto_free(Node.new())
	var spy_node = spy(instance)
	
	# verify we have no interactions currently on this instance
	verify_no_interactions(spy_node)

	assert_object(spy_node)\
		.is_not_null()\
		.is_instanceof(Node)\
		.is_not_same(instance)
	
	
	# call first time 
	spy_node.set_process(false)
	
	# verify is called one times
	verify(spy_node).set_process(false)
	# just double check that verify has no affect to the counter
	verify(spy_node).set_process(false)
	
	# call a scond time 
	spy_node.set_process(false)
	# verify is called two times
	verify(spy_node, 2).set_process(false)
	verify(spy_node, 2).set_process(false)


func test_spy_on_custom_class():
	var instance :AdvancedTestClass = auto_free(AdvancedTestClass.new())
	var spy_instance :AdvancedTestClass = spy(instance)
	
	# verify we have currently no interactions
	verify_no_interactions(spy_instance)
	
	assert_object(spy_instance)\
		.is_not_null()\
		.is_instanceof(AdvancedTestClass)\
		.is_not_same(instance)
		
	spy_instance.setup_local_to_scene()
	verify(spy_instance, 1).setup_local_to_scene()
	
	# call first time script func with different arguments
	spy_instance.get_area("test_a")
	spy_instance.get_area("test_b")
	spy_instance.get_area("test_c")
	
	# verify is each called only one time for different arguments
	verify(spy_instance, 1).get_area("test_a")
	verify(spy_instance, 1).get_area("test_b")
	verify(spy_instance, 1).get_area("test_c")
	# an second call with arg "test_c"
	spy_instance.get_area("test_c")
	verify(spy_instance, 1).get_area("test_a")
	verify(spy_instance, 1).get_area("test_b")
	verify(spy_instance, 2).get_area("test_c")
	
	# verify if a not used argument not counted
	verify(spy_instance, 0).get_area("test_no")


func test_spy_on_inner_class():
	var instance :AdvancedTestClass.AtmosphereData = auto_free(AdvancedTestClass.AtmosphereData.new())
	var spy_instance :AdvancedTestClass.AtmosphereData = spy(instance)
	
	# verify we have currently no interactions
	verify_no_interactions(spy_instance)
	
	assert_object(spy_instance)\
		.is_not_null()\
		.is_instanceof(AdvancedTestClass.AtmosphereData)\
		.is_not_same(instance)
		
	spy_instance.set_data(AdvancedTestClass.AtmosphereData.SMOKY, 1.2)
	spy_instance.set_data(AdvancedTestClass.AtmosphereData.SMOKY, 1.3)
	verify(spy_instance, 1).set_data(AdvancedTestClass.AtmosphereData.SMOKY, 1.2)
	verify(spy_instance, 1).set_data(AdvancedTestClass.AtmosphereData.SMOKY, 1.3)

func test_example_verify():
	var instance :Node = auto_free(Node.new())
	var spy_node = spy(instance)
	
	# verify we have no interactions currently on this instance
	verify_no_interactions(spy_node)
	
	# call with different arguments
	spy_node.set_process(false) # 1 times
	spy_node.set_process(true) # 1 times
	spy_node.set_process(true) # 2 times
	
	# verify how often we called the function with different argument 
	verify(spy_node, 2).set_process(true) # in sum two times with true
	verify(spy_node, 1).set_process(false)# in sum one time with false
	
	# verify total sum by using an argument matcher 
	verify(spy_node, 3).set_process(any_bool())

func test_verify_fail():
	var instance :Node = auto_free(Node.new())
	var spy_node = spy(instance)
	
	# interact two time
	spy_node.set_process(true) # 1 times
	spy_node.set_process(true) # 2 times
	
	# verify we interacts two times
	verify(spy_node, 2).set_process(true)
	
	# verify should fail because we interacts two times and not one
	verify(spy_node, 1, GdUnitAssert.EXPECT_FAIL).set_process(true)
	var expected_error := """Expecting interacion on:
	'set_process(True :bool)'	1 time's
But found interactions on:
	'set_process(True :bool)'	2 time's"""
	expected_error = GdScriptParser.to_unix_format(expected_error)
	assert_last_error(expected_error)

func test_verify_func_interaction_wiht_PoolStringArray():
	var spy_instance :ClassWithPoolStringArrayFunc = spy(ClassWithPoolStringArrayFunc.new())
	
	spy_instance.set_values(PoolStringArray())
	
	verify(spy_instance).set_values(PoolStringArray())
	verify_no_more_interactions(spy_instance)

func test_verify_func_interaction_wiht_PoolStringArray_fail():
	var spy_instance :ClassWithPoolStringArrayFunc = spy(ClassWithPoolStringArrayFunc.new())
	
	spy_instance.set_values(PoolStringArray())
	
	# try to verify with default array type instead of PoolStringArray type
	verify(spy_instance, 1, GdUnitAssert.EXPECT_FAIL).set_values([])
	var expected_error := """Expecting interacion on:
	'set_values([] :Array)'	1 time's
But found interactions on:
	'set_values([] :PoolStringArray)'	1 time's"""
	expected_error = GdScriptParser.to_unix_format(expected_error)
	assert_last_error(expected_error)
	
	reset(spy_instance)
	# try again with called two times and different args
	spy_instance.set_values(PoolStringArray())
	spy_instance.set_values(PoolStringArray(["a", "b"]))
	spy_instance.set_values([1, 2])
	verify(spy_instance, 1, GdUnitAssert.EXPECT_FAIL).set_values([])
	expected_error = """Expecting interacion on:
	'set_values([] :Array)'	1 time's
But found interactions on:
	'set_values([] :PoolStringArray)'	1 time's
	'set_values([a, b] :PoolStringArray)'	1 time's
	'set_values([1, 2] :Array)'	1 time's"""
	expected_error = GdScriptParser.to_unix_format(expected_error)
	assert_last_error(expected_error)

func test_reset():
	var instance :Node = auto_free(Node.new())
	var spy_node = spy(instance)
	
	# call with different arguments
	spy_node.set_process(false) # 1 times
	spy_node.set_process(true) # 1 times
	spy_node.set_process(true) # 2 times
	
	verify(spy_node, 2).set_process(true)
	verify(spy_node, 1).set_process(false)
	
	# now reset the spy
	reset(spy_node)
	# verify all counters have been reset
	verify_no_interactions(spy_node)

func test_verify_no_interactions():
	var instance :Node = auto_free(Node.new())
	var spy_node = spy(instance)
	
	# verify we have no interactions on this mock
	verify_no_interactions(spy_node)

func test_verify_no_interactions_fails():
	var instance :Node = auto_free(Node.new())
	var spy_node = spy(instance)
	
	# interact
	spy_node.set_process(false) # 1 times
	spy_node.set_process(true) # 1 times
	spy_node.set_process(true) # 2 times
	
	var expected_error ="""Expecting no more interacions!
But found interactions on:
	'set_process(False :bool)'	1 time's
	'set_process(True :bool)'	2 time's"""
	expected_error = GdScriptParser.to_unix_format(expected_error)
	# it should fail because we have interactions 
	verify_no_interactions(spy_node, GdUnitAssert.EXPECT_FAIL)\
		.has_error_message(expected_error)

func test_verify_no_more_interactions():
	var instance :Node = auto_free(Node.new())
	var spy_node :Node = spy(instance)
	
	spy_node.is_a_parent_of(instance)
	spy_node.set_process(false)
	spy_node.set_process(true)
	spy_node.set_process(true)
	
	# verify for called functions
	verify(spy_node, 1).is_a_parent_of(instance)
	verify(spy_node, 2).set_process(true)
	verify(spy_node, 1).set_process(false)
	
	# There should be no more interactions on this mock
	verify_no_more_interactions(spy_node)

func test_verify_no_more_interactions_but_has():
	var instance :Node = auto_free(Node.new())
	var spy_node :Node = spy(instance)
	
	spy_node.is_a_parent_of(instance)
	spy_node.set_process(false)
	spy_node.set_process(true)
	spy_node.set_process(true)
	
	# now we simulate extra calls that we are not explicit verify
	spy_node.is_inside_tree()
	spy_node.is_inside_tree()
	# a function with default agrs
	spy_node.find_node("mask")
	# same function again with custom agrs
	spy_node.find_node("mask", false, false)
	
	# verify 'all' exclusive the 'extra calls' functions
	verify(spy_node, 1).is_a_parent_of(instance)
	verify(spy_node, 2).set_process(true)
	verify(spy_node, 1).set_process(false)
	
	# now use 'verify_no_more_interactions' to check we have no more interactions on this mock
	# but should fail with a collecion of all not validated interactions
	var expected_error ="""Expecting no more interacions!
But found interactions on:
	'is_inside_tree()'	2 time's
	'find_node(mask :String, True :bool, True :bool)'	1 time's
	'find_node(mask :String, False :bool, False :bool)'	1 time's"""
	expected_error = GdScriptParser.to_unix_format(expected_error)
	verify_no_more_interactions(spy_node, GdUnitAssert.EXPECT_FAIL)\
		.has_error_message(expected_error)

class ClassWithStaticFunctions:
	
	static func foo() -> void:
		pass
	
	static func bar():
		pass
	
func test_create_spy_static_func_untyped():
	var instance = spy(ClassWithStaticFunctions.new())
	assert_object(instance).is_not_null()

func test_spy_snake_case_named_class_by_resource_path():
	var instance_a = load("res://addons/gdUnit3/test/mocker/resources/snake_case.gd").new()
	var spy_a = spy(instance_a)
	assert_object(spy_a).is_not_null()
	
	spy_a._ready()
	verify(spy_a)._ready()
	verify_no_more_interactions(spy_a)
	
	var instance_b = load("res://addons/gdUnit3/test/mocker/resources/snake_case_class_name.gd").new()
	var spy_b = spy(instance_b)
	assert_object(spy_b).is_not_null()
	
	spy_b._ready()
	verify(spy_b)._ready()
	verify_no_more_interactions(spy_b)

func test_spy_snake_case_named_class_by_class():
	var spy = spy(snake_case_class_name.new())
	assert_object(spy).is_not_null()
	
	spy._ready()
	verify(spy)._ready()
	verify_no_more_interactions(spy)
	
	# try on Godot class
	var spy_tcp_server :TCP_Server = spy(TCP_Server.new())
	assert_object(spy_tcp_server).is_not_null()
	
	spy_tcp_server.is_listening()
	spy_tcp_server.is_connection_available()
	verify(spy_tcp_server).is_listening()
	verify(spy_tcp_server).is_connection_available()
	verify_no_more_interactions(spy_tcp_server)

var _test_signal_is_emited := false
func _emit_ready(a, b, c):
	prints("_emit_ready", a, b, c)
	_test_signal_is_emited = true

# https://github.com/MikeSchulze/gdUnit3/issues/38
func test_spy_Node_use_real_func_vararg():
	var spy_node :Node = spy(auto_free(Node.new()))
	assert_that(spy_node).is_not_null()
	
	assert_bool(_test_signal_is_emited).is_false()
	spy_node.connect("ready", self, "_emit_ready")
	spy_node.emit_signal("ready", "aa", "bb", "cc")
	
	# sync signal is emited
	yield(get_tree(), "idle_frame")
	assert_bool(_test_signal_is_emited).is_true()

class ClassWithSignal:
	signal test_signal_a
	signal test_signal_b
	
	func foo(arg :int) -> void:
		if arg == 0:
			emit_signal("test_signal_a", "aa")
		else:
			emit_signal("test_signal_b", "bb", true)
	
	func bar(arg :int) -> bool:
		if arg == 0:
			emit_signal("test_signal_a", "aa")
		else:
			emit_signal("test_signal_b", "bb", true)
		return true

func test_spy_verify_emit_signal():
	var spy_instance :ClassWithSignal = spy(ClassWithSignal.new())
	assert_that(spy_instance).is_not_null()
	
	spy_instance.foo(0)
	verify(spy_instance, 1).emit_signal("test_signal_a", "aa")
	verify(spy_instance, 0).emit_signal("test_signal_b", "bb", true)
	reset(spy_instance)

	spy_instance.foo(1)
	verify(spy_instance, 0).emit_signal("test_signal_a", "aa")
	verify(spy_instance, 1).emit_signal("test_signal_b", "bb", true)
	reset(spy_instance)
	
	spy_instance.bar(0)
	verify(spy_instance, 1).emit_signal("test_signal_a", "aa")
	verify(spy_instance, 0).emit_signal("test_signal_b", "bb", true)
	reset(spy_instance)
	
	spy_instance.bar(1)
	verify(spy_instance, 0).emit_signal("test_signal_a", "aa")
	verify(spy_instance, 1).emit_signal("test_signal_b", "bb", true)

func test_spy_func_with_default_build_in_type():
	var spy_instance :ClassWithDefaultBuildIntTypes = spy(ClassWithDefaultBuildIntTypes.new())
	assert_object(spy_instance).is_not_null()
	# call with default arg
	spy_instance.foo("abc")
	spy_instance.bar("def")
	verify(spy_instance).foo("abc", Color.red)
	verify(spy_instance).bar("def", Vector3.FORWARD, AABB())
	verify_no_more_interactions(spy_instance)
	
	# call with custom args
	spy_instance.foo("abc", Color.blue)
	spy_instance.bar("def", Vector3.DOWN, AABB(Vector3.ONE, Vector3.ZERO))
	verify(spy_instance).foo("abc", Color.blue)
	verify(spy_instance).bar("def", Vector3.DOWN, AABB(Vector3.ONE, Vector3.ZERO))
	verify_no_more_interactions(spy_instance)

func test_spy_scene_by_path():
	var spy_scene = spy("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	# must fail spy is only allowed on a instance
	assert_object(spy_scene).is_null()

func test_spy_on_PackedScene():
	var resource := load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var original_script = resource.get_script()
	assert_object(resource).is_instanceof(PackedScene)
	
	var spy_scene = spy(resource)
	
	assert_object(spy_scene)\
		.is_not_null()\
		.is_not_instanceof(PackedScene)\
		.is_not_same(resource)
	assert_object(spy_scene.get_script())\
		.is_not_null()\
		.is_instanceof(GDScript)\
		.is_not_same(original_script)
	assert_str(spy_scene.get_script().resource_name).is_equal("SpyTestScene.gd")
	# check is mocked scene registered for auto freeing
	assert_bool(GdUnitTools.is_auto_free_registered(spy_scene, get_meta("MEMORY_POOL"))).is_true()

func test_spy_scene_by_instance():
	var resource := load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var instance :Control = resource.instance()
	var original_script = instance.get_script()
	var spy_scene = spy(instance)
	
	assert_object(spy_scene)\
		.is_not_null()\
		.is_same(instance)\
		.is_instanceof(Control)
	assert_object(spy_scene.get_script())\
		.is_not_null()\
		.is_instanceof(GDScript)\
		.is_not_same(original_script)
	assert_str(spy_scene.get_script().resource_name).is_equal("SpyTestScene.gd")
	# check is mocked scene registered for auto freeing
	assert_bool(GdUnitTools.is_auto_free_registered(spy_scene, get_meta("MEMORY_POOL"))).is_true()

func test_spy_scene_by_path_fail_has_no_script_attached():
	var resource := load("res://addons/gdUnit3/test/mocker/resources/scenes/TestSceneWithoutScript.tscn")
	var instance :Control = auto_free(resource.instance())
	
	# has to fail and return null
	var spy_scene = spy(instance)
	assert_object(spy_scene).is_null()

func test_spy_scene_initalize():
	var resource := load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn")
	var instance :Control = auto_free(resource.instance())
	var spy_scene = spy(instance)
	assert_object(spy_scene).is_not_null()
	
	# Add as child to a scene tree to trigger _ready to initalize all variables
	add_child(spy_scene)
	assert_object(spy_scene._box1).is_not_null()
	assert_object(spy_scene._box2).is_not_null()
	assert_object(spy_scene._box3).is_not_null()
	
	# check signals are connected
	assert_bool(spy_scene.is_connected("panel_color_change", spy_scene, "_on_panel_color_changed"))
	
	# check exports
	assert_str(spy_scene._initial_color.to_html()).is_equal(Color.red.to_html())

class_name GdUnitSpyTest
extends GdUnitTestSuite

# small helper to verify last assert error
static func assert_last_error(expected :String):
	var gd_assert := GdUnitAssertImpl.new("")
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
	var expexted_error := """Expecting interacion on:
	'set_process(True :bool)'	1 time's
But found interactions on:
	'set_process(True :bool)'	2 time's"""
	assert_last_error(expexted_error)

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

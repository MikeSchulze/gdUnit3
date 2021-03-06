extends GdUnitTestSuite

var resource_path := "res://addons/gdUnit3/test/mocker/resources/"

func before():
	# disable error pushing for testing
	GdUnitMockBuilder.do_push_errors(false)

func after():
	GdUnitMockBuilder.do_push_errors(true)

func test_is_mockable_godot_classes():
	# verify enigne classes
	for clazz_name in ClassDB.get_class_list():
		# mocking is not allowed for:
		# singleton classes
		# unregistered classes in ClassDB
		# protected classes (name starts with underscore)
		var is_mockable :bool = not Engine.has_singleton(clazz_name) and ClassDB.can_instance(clazz_name) and clazz_name.find("_") != 0
		assert_that(GdUnitMockBuilder.is_mockable(clazz_name)) \
			.as_error_message("Class '%s' expect mockable %s" % [clazz_name, is_mockable]) \
			.is_equal(is_mockable)

func test_is_mockable_by_class_type():
	assert_that(GdUnitMockBuilder.is_mockable(Node)).is_true()
	assert_that(GdUnitMockBuilder.is_mockable(CSGBox)).is_true()

func test_is_mockable_custom_class_type():
	assert_that(GdUnitMockBuilder.is_mockable(CustomResourceTestClass)).is_true()
	assert_that(GdUnitMockBuilder.is_mockable(CustomNodeTestClass)).is_true()

func test_is_mockable_by_script_path():
	assert_that(GdUnitMockBuilder.is_mockable(resource_path + "CustomResourceTestClass.gd")).is_true()
	assert_that(GdUnitMockBuilder.is_mockable(resource_path + "CustomNodeTestClass.gd")).is_true()
	# verify for non scripts
	assert_that(GdUnitMockBuilder.is_mockable(resource_path + "capsuleshape2d.tres")).is_false()

func test_is_mockable__overriden_func_get_class():
	# test with class type
	assert_that(GdUnitMockBuilder.is_mockable(OverridenGetClassTestClass))\
		.as_error_message("The class 'CustomResourceTestClass' should be mockable when 'func get_class()' is overriden")\
		.is_true()
	# test with resource path
	assert_that(GdUnitMockBuilder.is_mockable(resource_path + "OverridenGetClassTestClass.gd"))\
		.as_error_message("The class 'CustomResourceTestClass' should be mockable when 'func get_class()' is overriden")\
		.is_true()


func test_mock_godot_class_fullcheck(fuzzer=GodotClassNameFuzzer.new(), fuzzer_iterations=200):
	var clazz_name = fuzzer.next_value()
	# try to create a mock
	if GdUnitMockBuilder.is_mockable(clazz_name):
		var mock = mock(clazz_name, CALL_REAL_FUNC)
		assert_that(mock)\
			.as_error_message("The class %s should be mockable" % clazz_name)\
			.is_not_null()

func test_mock_by_script_path():
	assert_that(mock(resource_path + "CustomResourceTestClass.gd")).is_not_null()
	assert_that(mock(resource_path + "CustomNodeTestClass.gd")).is_not_null()

func test_mock_class__overriden_func_get_class():
	assert_that(mock(OverridenGetClassTestClass)).is_not_null()
	assert_that(mock(resource_path + "OverridenGetClassTestClass.gd")).is_not_null()

func test_mock_fail():
	# not godot class
	assert_that(mock("CustomResourceTestClass")).is_null()
	# invalid path to script
	assert_that(mock("invalid/CustomResourceTestClass.gd")).is_null()
	# try to mocking an existing instance is not allowed
	assert_that(mock(CustomResourceTestClass.new())).is_null()

func test_mock_special_classes():
	var mock = mock("JavaClass") as JavaClass
	assert_that(mock).is_not_null()

func test_mock_Node():
	var mocked_node : Node = mock(Node)
	assert_that(mocked_node).is_not_null()
	
	# test we have initial no interactions on this mock
	verify_no_interactions(mocked_node)
	
	# verify we have never called 'get_child_count()'
	verify(mocked_node, 0).get_child_count()
	
	# call 'get_child_count()' once 
	mocked_node.get_child_count()
	# verify we have called at once
	verify(mocked_node).get_child_count()
	
	# call function 'get_child_count' a second time 
	mocked_node.get_child_count()
	# verify we have called at twice
	verify(mocked_node, 2).get_child_count()
	
	
	# test mocked function returns default typed value
	assert_that(mocked_node.get_child_count()).is_equal(0)
	# now mock return value for function 'foo' to 'overwriten value'
	do_return(24).on(mocked_node).get_child_count()
	# verify the return value is overwritten
	assert_that(mocked_node.get_child_count()).is_equal(24)

func test_mock_custom_class_by_class_name():
	var mock = mock(CustomResourceTestClass)
	assert_that(mock).is_not_null()
	
	# test we have initial no interactions on this mock
	verify_no_interactions(mock)
	# test mocked function returns default typed value
	assert_that(mock.foo()).is_equal("")
	
	# now mock return value for function 'foo' to 'overwriten value'
	do_return("overriden value").on(mock).foo()
	# verify the return value is overwritten
	assert_that(mock.foo()).is_equal("overriden value")
	
	# now mock return values by custom arguments
	do_return("arg_1").on(mock).bar(1)
	do_return("arg_2").on(mock).bar(2)
	
	assert_that(mock.bar(1)).is_equal("arg_1")
	assert_that(mock.bar(2)).is_equal("arg_2")

func test_mock_custom_class_by_resource_path():
	var mock = mock("res://addons/gdUnit3/test/mocker/resources/CustomResourceTestClass.gd")
	assert_that(mock).is_not_null()
	
	# test we have initial no interactions on this mock
	verify_no_interactions(mock)
	# test mocked function returns default typed value
	assert_that(mock.foo()).is_equal("")
	
	# now mock return value for function 'foo' to 'overwriten value'
	do_return("overriden value").on(mock).foo()
	# verify the return value is overwritten
	assert_that(mock.foo()).is_equal("overriden value")
	
	# now mock return values by custom arguments
	do_return("arg_1").on(mock).bar(1)
	do_return("arg_2").on(mock).bar(2)
	
	assert_that(mock.bar(1)).is_equal("arg_1")
	assert_that(mock.bar(2)).is_equal("arg_2")


func test_mock_custom_class_func_foo_use_real_func():
	var mock = mock(CustomResourceTestClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	# test mocked function returns value from real function
	assert_that(mock.foo()).is_equal("foo")
	# now mock return value for function 'foo' to 'overwriten value'
	do_return("overridden value").on(mock).foo()
	# verify the return value is overwritten
	assert_that(mock.foo()).is_equal("overridden value")


func test_mock_custom_class_void_func():
	var mock = mock(CustomResourceTestClass)
	assert_that(mock).is_not_null()
	# test mocked void function returns null by default
	assert_that(mock.foo_void()).is_null()
	# try now mock return value for a void function. results into an error
	do_return("overridden value").on(mock).foo_void()
	# verify it has no affect for void func
	assert_that(mock.foo_void()).is_null()

func test_mock_custom_class_void_func_real_func():
	var mock = mock(CustomResourceTestClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	# test mocked void function returns null by default
	assert_that(mock.foo_void()).is_null()
	# try now mock return value for a void function. results into an error
	do_return("overridden value").on(mock).foo_void()
	# verify it has no affect for void func
	assert_that(mock.foo_void()).is_null()


func test_mock_custom_class_func_foo_call_times():
	var mock = mock(CustomResourceTestClass)
	assert_that(mock).is_not_null()
	verify(mock, 0).foo()
	mock.foo()
	verify(mock, 1).foo()
	mock.foo()
	verify(mock, 2).foo()
	mock.foo()
	mock.foo()
	verify(mock, 4).foo()

func test_mock_custom_class_func_foo_call_times_real_func():
	var mock = mock(CustomResourceTestClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	verify(mock, 0).foo()
	mock.foo()
	verify(mock, 1).foo()
	mock.foo()
	verify(mock, 2).foo()
	mock.foo()
	mock.foo()
	verify(mock, 4).foo()


func test_mock_custom_class_func_foo_full_test():
	var mock = mock(CustomResourceTestClass)
	assert_that(mock).is_not_null()
	verify(mock, 0).foo()
	assert_that(mock.foo()).is_equal("")
	verify(mock, 1).foo()
	do_return("new value").on(mock).foo()
	verify(mock, 1).foo()
	assert_that(mock.foo()).is_equal("new value")
	verify(mock, 2).foo()

func test_mock_custom_class_func_foo_full_test_real_func():
	var mock = mock(CustomResourceTestClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	verify(mock, 0).foo()
	assert_that(mock.foo()).is_equal("foo")
	verify(mock, 1).foo()
	do_return("new value").on(mock).foo()
	verify(mock, 1).foo()
	assert_that(mock.foo()).is_equal("new value")
	verify(mock, 2).foo()


func test_mock_custom_class_func_bar():
	var mock = mock(CustomResourceTestClass)
	assert_that(mock).is_not_null()
	assert_that(mock.bar(10)).is_equal("")
	# verify 'bar' with args [10] is called one time at this point
	verify(mock, 1).bar(10)
	# verify 'bar' with args [10, 20] is never called at this point
	verify(mock, 0).bar(10, 29)
	# verify 'bar' with args [23] is never called at this point
	verify(mock, 0).bar(23)

	# now mock return value for function 'bar' with args [10] to 'overwriten value'
	do_return("overridden value").on(mock).bar(10)
	# verify the return value is overwritten
	assert_that(mock.bar(10)).is_equal("overridden value")
	# finally verify function call times
	verify(mock, 2).bar(10)
	verify(mock, 0).bar(10, 29)
	verify(mock, 0).bar(23)

func test_mock_custom_class_func_bar_real_func():
	var mock = mock(CustomResourceTestClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	assert_that(mock.bar(10)).is_equal("test_33")
	# verify 'bar' with args [10] is called one time at this point
	verify(mock, 1).bar(10)
	# verify 'bar' with args [10, 20] is never called at this point
	verify(mock, 0).bar(10, 29)
	# verify 'bar' with args [23] is never called at this point
	verify(mock, 0).bar(23)

	# now mock return value for function 'bar' with args [10] to 'overwriten value'
	do_return("overridden value").on(mock).bar(10)
	# verify the return value is overwritten
	assert_that(mock.bar(10)).is_equal("overridden value")
	# verify the real implementation is used
	assert_that(mock.bar(10, 29)).is_equal("test_39")
	assert_that(mock.bar(10, 20, "other")).is_equal("other_30")
	# finally verify function call times
	verify(mock, 2).bar(10)
	verify(mock, 1).bar(10, 29)
	verify(mock, 0).bar(10, 20)
	verify(mock, 1).bar(10, 20, "other")

func test_mock_custom_class_extends_Node():
	var mock = mock(CustomNodeTestClass)
	assert_that(mock).is_not_null()
	
	# test mocked function returns null as default
	assert_that(mock.get_child_count()).is_equal(0)
	assert_that(mock.get_children()).contains_exactly([])
	# test seters has no affect
	var node = auto_free(Node.new())
	mock.add_child(node)
	assert_that(mock.get_child_count()).is_equal(0)
	assert_that(mock.get_children()).contains_exactly([])
	verify(mock, 1).add_child(node)
	verify(mock, 2).get_child_count()
	verify(mock, 2).get_children()

func test_mock_custom_class_extends_Node_real_func():
	var mock = mock(CustomNodeTestClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	# test mocked function returns default mock value
	assert_that(mock.get_child_count()).is_equal(0)
	assert_that(mock.get_children()).is_equal([])
	# test real seters used
	var nodeA = auto_free(Node.new())
	var nodeB = auto_free(Node.new())
	var nodeC = auto_free(Node.new())
	mock.add_child(nodeA)
	mock.add_child(nodeB)
	assert_that(mock.get_child_count()).is_equal(2)
	assert_that(mock.get_children()).contains_exactly([nodeA, nodeB])
	verify(mock, 1).add_child(nodeA)
	verify(mock, 1).add_child(nodeB)
	verify(mock, 0).add_child(nodeC)
	verify(mock, 2).get_child_count()
	verify(mock, 2).get_children()

func test_mock_custom_class_extends_other_custom_class():
	var mock :CustomClassExtendsCustomClass = mock(CustomClassExtendsCustomClass)
	assert_that(mock).is_not_null()
	
	# foo() form parent class
	verify(mock, 0).foo()
	# foo2() overriden 
	verify(mock, 0).foo2()
	# bar2() from class 
	verify(mock, 0).bar2()
	
	assert_that(mock.foo()).is_empty()
	assert_that(mock.foo2()).is_null()
	assert_that(mock.bar2()).is_empty()
	
	verify(mock, 1).foo()
	verify(mock, 1).foo2()
	verify(mock, 1).bar2()
	
	# override returns
	do_return("abc1").on(mock).foo()
	do_return("abc2").on(mock).foo2()
	do_return("abc3").on(mock).bar2()
	
	assert_that(mock.foo()).is_equal("abc1")
	assert_that(mock.foo2()).is_equal("abc2")
	assert_that(mock.bar2()).is_equal("abc3")


func test_mock_custom_class_extends_other_custom_class_call_real_func():
	var mock :CustomClassExtendsCustomClass = mock(CustomClassExtendsCustomClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	
	# foo() form parent class
	verify(mock, 0).foo()
	# foo2() overriden 
	verify(mock, 0).foo2()
	# bar2() from class 
	verify(mock, 0).bar2()
	
	assert_that(mock.foo()).is_equal("foo")
	assert_that(mock.foo2()).is_equal("foo2 overriden")
	assert_that(mock.bar2()).is_equal("test_65")
	
	verify(mock, 1).foo()
	verify(mock, 1).foo2()
	verify(mock, 1).bar2()
	
	# override returns
	do_return("abc1").on(mock).foo()
	do_return("abc2").on(mock).foo2()
	do_return("abc3").on(mock).bar2()
	
	assert_that(mock.foo()).is_equal("abc1")
	assert_that(mock.foo2()).is_equal("abc2")
	assert_that(mock.bar2()).is_equal("abc3")

func test_mock_static_func():
	var mock := mock(CustomNodeTestClass) as CustomNodeTestClass
	assert_that(mock).is_not_null()
	# initial not called
	verify(mock, 0).static_test()
	verify(mock, 0).static_test_void()

	assert_that(mock.static_test()).is_equal("")
	assert_that(mock.static_test_void()).is_null()

	verify(mock, 1).static_test()
	verify(mock, 1).static_test_void()
	mock.static_test()
	mock.static_test_void()
	mock.static_test_void()
	verify(mock, 2).static_test()
	verify(mock, 3).static_test_void()

func test_mock_static_func_real_func():
	var mock := mock(CustomNodeTestClass, CALL_REAL_FUNC) as CustomNodeTestClass
	assert_that(mock).is_not_null()
	# initial not called
	verify(mock, 0).static_test()
	verify(mock, 0).static_test_void()

	assert_that(mock.static_test()).is_equal(CustomNodeTestClass.STATIC_FUNC_RETURN_VALUE)
	assert_that(mock.static_test_void()).is_null()

	verify(mock, 1).static_test()
	verify(mock, 1).static_test_void()
	mock.static_test()
	mock.static_test_void()
	mock.static_test_void()
	verify(mock, 2).static_test()
	verify(mock, 3).static_test_void()


func _test_mock_mode_deep_stub():
	var mocked_shape = mock(DeepStubTestClass.XShape)
	#var t := DeepStubTestClass.new()
	#t.add(mocked_shape)
	#assert_bool(t.validate()).is_true()


func test_mock_custom_class_assert_has_no_side_affect():
	var mock = mock(CustomNodeTestClass)
	assert_that(mock).is_not_null()
	var node = Node.new()
	# verify the assertions has no side affect on mocked object
	verify(mock, 0).add_child(node)
	# expect no change on childrens
	assert_that(mock.get_children()).contains_exactly([])

	mock.add_child(node)
	# try thre times 'assert_called' to see it has no affect to the mock
	verify(mock, 1).add_child(node)
	verify(mock, 1).add_child(node)
	verify(mock, 1).add_child(node)
	assert_that(mock.get_children()).contains_exactly([])
	# needs to be manually freed
	node.free()

func test_mock_custom_class_assert_has_no_side_affect_real_func():
	var mock = mock(CustomNodeTestClass, CALL_REAL_FUNC)
	assert_that(mock).is_not_null()
	var node = Node.new()
	# verify the assertions has no side affect on mocked object
	verify(mock, 0).add_child(node)
	# expect no change on childrens
	assert_that(mock.get_children()).contains_exactly([])

	mock.add_child(node)
	# try thre times 'assert_called' to see it has no affect to the mock
	verify(mock, 1).add_child(node)
	verify(mock, 1).add_child(node)
	verify(mock, 1).add_child(node)
	assert_that(mock.get_children()).contains_exactly([node])


# This test verifies a function is calling other internally functions
# to collect the access times and the override return value is working as expected
func test_mock_advanced_func_path():
	var mock := mock(AdvancedTestClass, CALL_REAL_FUNC) as AdvancedTestClass
	# initial nothing is called
	verify(mock, 0).select(AdvancedTestClass.A)
	verify(mock, 0).select(AdvancedTestClass.B)
	verify(mock, 0).select(AdvancedTestClass.C)
	verify(mock, 0).a()
	verify(mock, 0).b()
	verify(mock, 0).c()

	# the function select() swiches based on input argument to function a(), b() or c()
	# call select where called internally func a() and returned "a"
	assert_that(mock.select(AdvancedTestClass.A)).is_equal("a")
	# verify when call select() is also calling original func a()
	verify(mock, 1).select(AdvancedTestClass.A)
	verify(mock, 1).a()

	# call select again wiht overriden return value for func a()
	do_return("overridden a func").on(mock).a()
	assert_that(mock.select(AdvancedTestClass.A)).is_equal("overridden a func")

	# verify at this time select() and a() is called two times
	verify(mock, 2).select(AdvancedTestClass.A)
	verify(mock, 0).select(AdvancedTestClass.B)
	verify(mock, 0).select(AdvancedTestClass.C)
	verify(mock, 2).a()
	verify(mock, 0).b()
	verify(mock, 0).c()

	# finally use select to switch to internally func c()
	assert_that(mock.select(AdvancedTestClass.C)).is_equal("c")
	verify(mock, 2).select(AdvancedTestClass.A)
	verify(mock, 0).select(AdvancedTestClass.B)
	verify(mock, 1).select(AdvancedTestClass.C)
	verify(mock, 2).a()
	verify(mock, 0).b()
	verify(mock, 1).c()

func test_mock_godot_class_calls_sub_function():
	var mock := mock(MeshInstance, CALL_REAL_FUNC) as MeshInstance
	verify(mock, 0)._mesh_changed()
	mock.set_mesh(QuadMesh.new())
	verify(mock, 1).set_mesh(any_class(Mesh))
	verify(mock, 1)._mesh_changed()

func test_mock_class_with_inner_classs():
	var mock_advanced := mock(AdvancedTestClass) as AdvancedTestClass
	assert_that(mock_advanced).is_not_null()

	var mock_a := mock(AdvancedTestClass.SoundData) as AdvancedTestClass.SoundData
	assert_object(mock_a).is_not_null()

	var mock_b := mock(AdvancedTestClass.AtmosphereData) as AdvancedTestClass.AtmosphereData
	assert_object(mock_b).is_not_null()
	
	var mock_c := mock(AdvancedTestClass.Area4D) as AdvancedTestClass.Area4D
	assert_object(mock_c).is_not_null()

func test_example_do_return():
	var mocked_node : Node = mock(Node)

	# is return 0 by default
	mocked_node.get_child_count()
	# configure to return 10 when 'get_child_count()' is called
	do_return(10).on(mocked_node).get_child_count()
	# will now return 10
	mocked_node.get_child_count()
	
	# is return 'null' by default
	var node = mocked_node.get_child(0)
	assert_object(node).is_null()
	
	# configure to return a mocked 'Camera' for child 0
	do_return(mock(Camera)).on(mocked_node).get_child(0)
	# configure to return a mocked 'Area' for child 1
	do_return(mock(Area)).on(mocked_node).get_child(1)
	
	# will now return the Camera node
	var node0 = mocked_node.get_child(0)
	assert_object(node0).is_instanceof(Camera)
	# will now return the Area node
	var node1 = mocked_node.get_child(1)
	assert_object(node1).is_instanceof(Area)

func test_example_verify():
	var mocked_node :Node = mock(Node)
	
	# verify we have no interactions currently on this instance
	verify_no_interactions(mocked_node)
	
	# call with different arguments
	mocked_node.set_process(false) # 1 times
	mocked_node.set_process(true) # 1 times
	mocked_node.set_process(true) # 2 times
	
	# verify how often we called the function with different argument 
	verify(mocked_node, 2).set_process(true) # in sum two times with true
	verify(mocked_node, 1).set_process(false)# in sum one time with false

	# verify total sum by using an argument matcher 
	verify(mocked_node, 3).set_process(any_bool())

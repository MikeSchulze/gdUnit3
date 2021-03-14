class_name GdUnitSpyTest
extends GdUnitTestSuite


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
	
	
class ClassWithStaticFunctions:
	
	static func foo() -> void:
		pass
	
	static func bar():
		pass
	
func test_create_spy_static_func_untyped():
	var instance = spy(ClassWithStaticFunctions.new())
	assert_object(instance).is_not_null()

# GdUnit generated TestSuite
class_name GdUnitObjectAssertImplTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit3/src/asserts/GdUnitObjectAssertImpl.gd'

func test_is_equal():
	assert_object(Mesh.new()).is_equal(Mesh.new())
	# should fail because the current is an Mesh and we expect equal to a Skin
	assert_object(Mesh.new(), GdUnitAssert.EXPECT_FAIL)\
		.is_equal(Skin.new())
	assert_object(null, GdUnitAssert.EXPECT_FAIL)\
		.is_equal(Skin.new())\
		.has_failure_message("Expecting:\n"
			+ " <Skin>\n"
			+ " but was\n"
			+ " 'Null'")

func test_is_not_equal():
	assert_object(null).is_not_equal(Skin.new())
	assert_object(Mesh.new()).is_not_equal(Skin.new())
	# should fail because the current is an Mesh and we expect not equal to a Mesh
	assert_object(Mesh.new(), GdUnitAssert.EXPECT_FAIL)\
		.is_not_equal(Mesh.new())

func test_is_instanceof():
	# engine class test
	assert_object(auto_free(Path.new())).is_instanceof(Node)
	assert_object(auto_free(Camera.new())).is_instanceof(Camera)
	# script class test
	assert_object(auto_free(Udo.new())).is_instanceof(Person)
	# inner class test
	assert_object(auto_free(CustomClass.InnerClassA.new())).is_instanceof(Node)
	assert_object(auto_free(CustomClass.InnerClassB.new())).is_instanceof(CustomClass.InnerClassA)
	
	# should fail because the current is not a instance of `Tree`
	assert_object(auto_free(Path.new()), GdUnitAssert.EXPECT_FAIL)\
		.is_instanceof(Tree)\
		.has_failure_message("Expected instance of:\n 'Tree'\n But it was 'Path'")
	assert_object(null, GdUnitAssert.EXPECT_FAIL)\
		.is_instanceof(Tree)\
		.has_failure_message("Expected instance of:\n 'Tree'\n But it was 'Null'")

func test_is_not_instanceof():
	assert_object(null).is_not_instanceof(Tree)
	# engine class test
	assert_object(auto_free(Path.new())).is_not_instanceof(Tree)
	# script class test
	assert_object(auto_free(City.new())).is_not_instanceof(Person)
	# inner class test
	assert_object(auto_free(CustomClass.InnerClassA.new())).is_not_instanceof(Tree)
	assert_object(auto_free(CustomClass.InnerClassB.new())).is_not_instanceof(CustomClass.InnerClassC)
	
	# should fail because the current is not a instance of `Tree`
	assert_object(auto_free(Path.new()), GdUnitAssert.EXPECT_FAIL)\
		.is_not_instanceof(Node)\
		.has_failure_message("Expected not be a instance of <Node>")

func test_is_null():
	assert_object(null).is_null()
	# should fail because the current is not null
	assert_object(auto_free(Node.new()), GdUnitAssert.EXPECT_FAIL) \
		.is_null()\
		.starts_with_failure_message("Expecting: 'Null' but was <Node>")

func test_is_not_null():
	assert_object(auto_free(Node.new())).is_not_null()
	# should fail because the current is null
	assert_object(null, GdUnitAssert.EXPECT_FAIL) \
		.is_not_null()\
		.has_failure_message("Expecting: not to be 'Null'")

func test_is_same():
	var obj1 = auto_free(Node.new())
	var obj2 = obj1
	var obj3 = auto_free(obj1.duplicate())
	assert_object(obj1).is_same(obj1)
	assert_object(obj1).is_same(obj2)
	assert_object(obj2).is_same(obj1)
	assert_object(null, GdUnitAssert.EXPECT_FAIL)\
		.is_same(obj1)\
		.has_failure_message("Expecting:\n"
			+ " <Node>\n"
			+ " to refer to the same object\n"
			+ " 'Null'")
	assert_object(obj1, GdUnitAssert.EXPECT_FAIL).is_same(obj3)
	assert_object(obj3, GdUnitAssert.EXPECT_FAIL).is_same(obj1)
	assert_object(obj3, GdUnitAssert.EXPECT_FAIL).is_same(obj2)

func test_is_not_same():
	var obj1 = auto_free(Node.new())
	var obj2 = obj1
	var obj3 = auto_free(obj1.duplicate())
	assert_object(null).is_not_same(obj1)
	assert_object(obj1).is_not_same(obj3)
	assert_object(obj3).is_not_same(obj1)
	assert_object(obj3).is_not_same(obj2)

	assert_object(obj1, GdUnitAssert.EXPECT_FAIL).is_not_same(obj1)
	assert_object(obj1, GdUnitAssert.EXPECT_FAIL).is_not_same(obj2)
	assert_object(obj2, GdUnitAssert.EXPECT_FAIL).is_not_same(obj1)

func test_must_fail_has_invlalid_type():
	assert_object(1, GdUnitAssert.EXPECT_FAIL) \
		.has_failure_message("GdUnitObjectAssert inital error, unexpected type <int>")
	assert_object(1.3, GdUnitAssert.EXPECT_FAIL) \
		.has_failure_message("GdUnitObjectAssert inital error, unexpected type <float>")
	assert_object(true, GdUnitAssert.EXPECT_FAIL) \
		.has_failure_message("GdUnitObjectAssert inital error, unexpected type <bool>")
	assert_object("foo", GdUnitAssert.EXPECT_FAIL) \
		.has_failure_message("GdUnitObjectAssert inital error, unexpected type <String>")

func test_override_failure_message() -> void:
	assert_object(auto_free(Node.new()), GdUnitAssert.EXPECT_FAIL)\
		.override_failure_message("Custom failure message")\
		.is_null()\
		.has_failure_message("Custom failure message")


var _index = -1
var _values := [Reference.new(), Reference.new(), Reference.new()]
func next_value() -> Object:
	_index += 1
	return _values[_index]

func test_with_value_provider() -> void:
	assert_object(CallBackValueProvider.new(self, "next_value"))\
		.is_equal(_values[0]).is_equal(_values[1]).is_equal(_values[2])

# tests if an assert fails the 'is_failure' reflects the failure status
func test_is_failure() -> void:
	# initial is false
	assert_bool(is_failure()).is_false()
	
	# on success assert
	assert_object(null).is_null()
	assert_bool(is_failure()).is_false()
	
	# on faild assert
	assert_object(Reference.new(), GdUnitAssert.EXPECT_FAIL).is_null()
	assert_bool(is_failure()).is_true()
	
	# on next success assert
	assert_object(null).is_null()
	# is true because we have an already failed assert
	assert_bool(is_failure()).is_true()
	
	# should abort here because we had an failing assert
	if is_failure():
		return
	assert_bool(true).override_failure_message("This line shold never be called").is_false()

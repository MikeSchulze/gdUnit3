# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitMockImpl

################################################################################
# internal mocking stuff
################################################################################
var __working_mode :String

var __do_return_value = null
var __saved_return_values := Dictionary()

# self reference holder, use this kind of hack to store static function calls 
# it is important to manually free by '__release_double' otherwise it ends up in orphan instance
const __self := []

func __set_singleton():
	# store self need to mock static functions
	__self.append(self)

func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	__self.clear()

func __is_prepare_return_value() -> bool:
	return __do_return_value != null

func __save_function_return_value(args :Array):
	__saved_return_values[args] = __do_return_value
	__do_return_value = null
	return __saved_return_values[args]

func __set_mode(mode :String):
	__working_mode = mode
	return self

func __do_return(value):
	__do_return_value = value
	return self

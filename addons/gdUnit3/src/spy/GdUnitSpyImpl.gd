# warnings-disable
# warning-ignore:unused_argument
class_name GdUnitSpyImpl

var __instance_delegator

# self reference holder, use this kind of hack to store static function calls 
# it is important to manually free by '__release_double' otherwise it ends up in orphan instance
const __self := []

func __set_singleton(instance):
	# store self need to mock static functions
	__self.append(self)
	__instance_delegator = instance

func __release_double():
	# we need to release the self reference manually to prevent orphan nodes
	__self.clear()
	__instance_delegator = null


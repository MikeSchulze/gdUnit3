################################################################################
# Provides access to a global accessible singleton 
# 
# This is a workarount to the existing auto load singleton because of some bugs 
# around plugin handling 
################################################################################
class_name GdUnitSingleton
extends Resource

const _singletons :Dictionary = Dictionary()

static func get_singleton(name: String) -> Object:
	if _singletons.has(name):
		return _singletons[name]
	push_error("No singleton instance with '" + name + "' found.")
	return null

static func add_singleton(name: String, path: String) -> Object:
	var singleton:Object = load(path).new()
	singleton.set_name(name)
	_singletons[name] = singleton
	#print_debug("Added singleton", name, singleton)
	return singleton

static func get_or_create_singleton(name: String, path: String) -> Object:
	if _singletons.has(name):
		return _singletons[name]
	return add_singleton(name, path)

static func remove_singleton(name: String) -> void:
	if _singletons.has(name):
		#print_debug("Remove singleton '" + name + "'")
		_singletons.erase(name)
		return
	push_error("Remove singleton '" + name + "' failed. No global instance found.")

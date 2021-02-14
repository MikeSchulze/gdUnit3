# fuzzer to get available godot class names
class_name GodotClassNameFuzzer
extends Fuzzer

var class_names := []
const EXCLUDED_CLASSES = ["JavaClass", "_ClassDB"]

func _init(no_singleton :bool = false, only_instancialbe :bool = false) -> void:
	#class_names = ClassDB.get_class_list()
	for clazz_name in ClassDB.get_class_list():
		if no_singleton and Engine.has_singleton(clazz_name):
			continue
		if only_instancialbe and not ClassDB.can_instance(clazz_name):
			continue
		# exclude special classes
		if EXCLUDED_CLASSES.has(clazz_name):
			continue
		class_names.push_back(clazz_name)

func next_value():
	return class_names[randi() % class_names.size()]

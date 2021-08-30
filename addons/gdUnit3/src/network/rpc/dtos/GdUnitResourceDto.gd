class_name GdUnitResourceDto
extends Resource

var _name :String
var _path :String

func serialize(resource :Object) -> Dictionary:
	var serialized := Dictionary()
	serialized["name"] = resource.get_name()
	var script = resource.get_script()
	if script:
		serialized["resource_path"] = script.resource_path
	return serialized

func deserialize(data :Dictionary) -> GdUnitResourceDto:
	_name = data.get("name", "n.a.")
	_path = data.get("resource_path", "")
	return self

func name() -> String:
	return _name

func path() -> String:
	return _path

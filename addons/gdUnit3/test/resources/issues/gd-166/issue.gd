extends Object

const Type = preload("types.gd")

var type = null setget _set_type
var type_name
	
func _set_type(t:int):
	type = t
	type_name = Type.to_str(t)
	print("type was set to %s" % type_name)

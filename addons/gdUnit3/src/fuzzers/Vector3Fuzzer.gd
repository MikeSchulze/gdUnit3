class_name Vector3Fuzzer
extends Fuzzer


var _from :Vector3
var _to : Vector3

func _init(from: Vector3, to: Vector3):
	assert(from <= to, "Invalid range!")
	_from = from
	_to = to

func next_value() -> Vector3:
	var x = rand_range(_from.x, _to.x)
	var y = rand_range(_from.y, _to.y)
	var z = rand_range(_from.z, _to.z)
	return Vector3(x, y, z)

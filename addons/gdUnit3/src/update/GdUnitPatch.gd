class_name GdUnitPatch
extends Reference

const PATCH_VERSION = "patch_version"

var _version :GdUnit3Version

func _init(version :GdUnit3Version):
	_version = version

func version() -> GdUnit3Version:
	return _version

# this function needs to be implement
func execute() -> bool:
	push_error("The function 'execute()' is not implemented at %s" % self)
	return false

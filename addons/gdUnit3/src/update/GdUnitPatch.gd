class_name GdUnitPatch
extends Reference

# this function needs to be implement
func execute() -> bool:
	push_error("The function 'execute()' is not implemented at %s" % self)
	return false

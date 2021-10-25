extends GdUnitPatch

func _init() .(GdUnit3Version.parse("v1.1.4")): 
	pass

func execute() -> bool:
	var patches := Array()
	if Engine.has_meta(PATCH_VERSION):
		patches = Engine.get_meta(PATCH_VERSION)
	patches.append(version())
	Engine.set_meta(PATCH_VERSION, patches)
	return true

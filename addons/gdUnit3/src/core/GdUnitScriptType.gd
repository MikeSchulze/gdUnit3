class_name GdUnitScriptType
extends Reference

const UNKNOWN := ""
const CS := "cs"
const GD := "gd"
const NATIVE := "gdns"
const VS := "vs"

static func type_of(script :Script) -> String:
	if script == null:
		return UNKNOWN
	if GdObjects.is_gd_script(script):
		return GD
	if GdObjects.is_vs_script(script):
		return VS
	if GdObjects.is_native_script(script):
		return NATIVE
	if GdUnit3MonoBridge.is_csharp_file(script.resource_path):
		return CS
	return UNKNOWN

class_name FuzzerTool
extends Resource

static func create_fuzzer(source:GDScript, function: String) -> Fuzzer:
	var source_code = "# warnings-disable\n" \
		+ source.source_code \
		+ "\n" \
		+ "func __fuzzer():\n" \
		+ "	var " + function + "\n" \
		+ "	return fuzzer\n"
	var script = GDScript.new()
	script.source_code = source_code
	var result = script.reload()
	if result != OK:
		prints("script loading error", result)
		return null

	var instance = script.new()	
	var f := funcref(instance, "__fuzzer")
	if not f.is_valid():
		prints("Error", script, f)
		return null
	var fuzzer = f.call_func()
	instance.free()
	if fuzzer is Fuzzer:
		return fuzzer as Fuzzer
	else:
		return null

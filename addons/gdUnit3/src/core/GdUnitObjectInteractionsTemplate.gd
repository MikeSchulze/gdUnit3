class_name GdUnitObjectInteractionsTemplate

var __expected_interactions :int = -1
var __saved_interactions := Dictionary()
var __verified_interactions := Array()

func __save_function_interaction(args :Array) -> void:
	__saved_interactions[args] = __saved_interactions.get(args, 0) + 1

func __is_verify_interactions() -> bool:
	return __expected_interactions != -1

func __do_verify_interactions(times :int = 1) -> Object:
	__expected_interactions = times
	return self

func __verify_interactions(args :Array):
	var summary := Dictionary()
	var total_interactions := 0
	var matcher := GdUnitArgumentMatchers.to_matcher(args)
	for key in __saved_interactions.keys():
		if matcher.is_match(key):
			var interactions :int = __saved_interactions.get(key, 0)
			total_interactions += interactions
			summary[key] = interactions
			# add as verified
			__verified_interactions.append(key)
	
	var gd_assert := GdUnitAssertImpl.new("", GdUnitAssert.EXPECT_SUCCESS)
	if summary.empty():
		gd_assert.report_success()
	elif total_interactions != __expected_interactions:
		gd_assert.report_error(GdAssertMessages.error_no_more_interactions(summary))
	__expected_interactions = -1

func __verify_no_interactions() -> Dictionary:
	var summary := Dictionary()
	if not __saved_interactions.empty():
		for func_call in __saved_interactions.keys():
			summary[func_call] = __saved_interactions[func_call]
	return summary

func __verify_no_more_interactions() -> Dictionary:
	var summary := Dictionary()
	var called_functions :Array = __saved_interactions.keys()
	if called_functions != __verified_interactions:
		# collect the not verified functions
		var called_but_not_verified := called_functions.duplicate()
		for verified_function in __verified_interactions:
			called_but_not_verified.erase(verified_function)
		
		for not_verified in called_but_not_verified:
			summary[not_verified] = __saved_interactions[not_verified]
	return summary

func __reset_interactions() -> void:
	__saved_interactions.clear()

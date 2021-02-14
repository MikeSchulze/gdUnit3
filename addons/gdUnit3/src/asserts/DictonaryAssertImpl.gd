class_name DictonaryAssertImpl
extends GdUnitAssertImpl


func is_equal(expected):
	if not GdObjects.equals(_current, expected):
		# TODO improve error report
		var l:String = ""
		var r:String = ""
		for key in expected.keys():
			l += str(key) + "=" + str(expected[key]) + "\n"
		for key in _current.keys():
			r += str(key) + "=" + str(_current[key])  + "\n"
		#GdAssertReports.report_error("Expected equals'\n" + l + "'\n but was \n'" + r +"'", self, get_stack())

#func is_not_equal(expected):
#	if GdObjects.equals(_current, expected):
#		GdAssertReports.report_error("Expected not equals'\n" + str(expected) + "' but was '" + str(_current) +"'", self, get_stack())


#func hasSize(expectd:int):
#	if funcref(_current, "size"):
#		if _current.size() != expectd:
#			return GdAssertReports.report_error("Expected size of" + str(expectd) + " but was " + str(_current.size()), self, get_stack())
#	else: if funcref(_current, "length"):
#		if _current.length() != expectd:
#			return GdAssertReports.report_error("Expected size of" + str(expectd) + " but was " + str(_current.length()), self, get_stack())
#	assert(false, "The type is not supported")
#	return GdAssertReports.report_success(self)

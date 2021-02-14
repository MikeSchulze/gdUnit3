extends GdUnitTestSuite


var _events :Array = Array()
var _test_data :Node

# normaly DONT do overwrite the constructor!!!
# we do it only for specal test to register for all gduint events
func _init():
	# register for report to collect all test events
	GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)\
		.register_on_gdunit_events(self, "_on_gdunit_event")

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			GdUnitSingleton.get_singleton(SignalHandler.SINGLETON_NAME)\
				.unregister_on_gdunit_events(self, "_on_gdunit_event")

func _on_gdunit_event(event :GdUnitEvent):
	# only append testsuite related events 
	if event.suite_name() == "TestExecutionEventHanderTest":
		_events.append(event)

func before():
	# create a node where is auto freed when the test-suite ends
	_test_data = auto_free(Node.new())
	# create a node where never freed (orphan)
	Node.new()

func before_test():
	assert_object(_test_data).is_not_null()
	_events.clear()
	Node.new()
	Node.new()

func test_ends_with_3_orphan_nodes():
	assert_object(_test_data).is_not_null()
	Node.new()
	Node.new()
	Node.new()

func test_ends_with_4_orphan_nodes():
	Node.new()
	Node.new()
	Node.new()
	Node.new()


# we want to verify a failing test emits an GdUnitEvent with error and the line number 
func test_ends_with_error():
	# should emit an error with line info 46
	assert_int(200).is_zero()

func after():
	for event in _events:
		if event.type() == GdUnitEvent.TESTSUITE_AFTER:
			assert_int(event.statistic(GdUnitEvent.STATISTICS.ORPHAN_NODES)).is_equal(3)

func after_test():
	assert_object(_test_data).is_not_null()
	for event in _events:
		if event.type() == GdUnitEvent.TESTCASE_AFTER:
			assert_int(event.statistic(GdUnitEvent.STATISTICS.ORPHAN_NODES)).is_equal(2)
		
		if event.type() == GdUnitEvent.TESTRUN_AFTER:
			if event.test_name() == "test_ends_with_3_orphan_nodes":
				assert_int(event.statistic(GdUnitEvent.ORPHAN_NODES)).is_equal(3)
			if event.test_name() == "test_ends_with_4_orphan_nodes":
				assert_int(event.statistic(GdUnitEvent.ORPHAN_NODES)).is_equal(4)
			if event.test_name() == "test_ends_with_error":
				var reports = event.reports()
				assert_array(reports).has_size(1)
				var report := reports[0] as GdUnitReport
				assert_int(report.type()).is_equal(GdUnitReport.ERROR)
				assert_int(report.line_number()).is_equal(47)

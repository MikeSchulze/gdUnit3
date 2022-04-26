extends GdUnitPatch

func _init() .(GdUnit3Version.parse("v1.1.0")):
	pass

func execute() -> bool:
	# migrate existing test-suite template by replacing old tags with new ones
	var old_template := GdUnitTestSuiteTemplate.load_template(GdUnitTestSuiteTemplate.TEMPLATE_ID_GD)
	var migrated_template := old_template\
		.replace("${class_name}", GdUnitTestSuiteTemplate.TAG_TEST_SUITE_CLASS)\
		.replace("${source_path}", GdUnitTestSuiteTemplate.TAG_SOURCE_RESOURCE_PATH)
	GdUnitTestSuiteTemplate.save_template(GdUnitTestSuiteTemplate.TEMPLATE_ID_GD, migrated_template)
	prints("Succesfull migrated test-suite template")
	return true

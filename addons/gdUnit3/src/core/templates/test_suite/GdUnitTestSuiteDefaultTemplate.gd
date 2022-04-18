class_name GdUnitTestSuiteDefaultTemplate
extends Reference


const DEFAULT_TEMP_TS_GD = \
"""# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name ${suite_class_name}
extends GdUnitTestSuite

# TestSuite generated from
const __source = '${source_resource_path}'
"""

const DEFAULT_TEMP_TS_CS = \
"""// GdUnit generated TestSuite

using Godot;

namespace ${project_name}.Tests
{
	using Exceptions;
	using static Assertions;

	[TestSuite]
	public class ${suite_class_name}
	{
		// TestSuite generated from
		private static string __source = "${source_resource_path}";
		
	}
}
"""

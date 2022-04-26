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
using GdUnit3;

namespace ${name_space}
{
	using static Assertions;
	using static Utils;

	[TestSuite]
	public class ${suite_class_name}
	{
		// TestSuite generated from
		private const string sourceClazzPath = "${source_resource_path}";
		
	}
}
"""

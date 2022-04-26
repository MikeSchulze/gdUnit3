using System.IO;
using System.Text;
using System.Collections.Generic;

namespace GdUnit3.Core.Tests
{
    using static Assertions;
    using static Utils;

    [TestSuite]
    public class GdUnitTestSuiteBuilderTest
    {

        [AfterTest]
        public void AfterEach()
        {
            ClearTempDir();
        }

        [TestCase]
        public void ParseType()
        {
            AssertObject(GdUnitTestSuiteBuilder.ParseType("addons/gdUnit3/test/core/resources/testsuites/mono/spaceA/TestSuite.cs")).IsEqual(typeof(GdUnit3.Tests.SpaceA.TestSuite));
            AssertObject(GdUnitTestSuiteBuilder.ParseType("addons/gdUnit3/test/core/resources/testsuites/mono/spaceB/TestSuite.cs")).IsEqual(typeof(GdUnit3.Tests.SpaceB.TestSuite));
            // source file not exists
            AssertObject(GdUnitTestSuiteBuilder.ParseType("addons/gdUnit3/test/core/resources/testsuites/mono/spaceC/TestSuite.cs")).IsNull();
        }

        [TestCase]
        public void FindMethod_LineOutOfRange()
        {
            var classPath = Godot.ProjectSettings.GlobalizePath("res://addons/gdUnit3/test/core/resources/sources/TestPerson.cs");
            AssertThrown(() => GdUnitTestSuiteBuilder.FindMethod(classPath, 0)).StartsWithMessage("Specified argument was out of the range of valid values.");
            AssertThrown(() => GdUnitTestSuiteBuilder.FindMethod(classPath, 10000)).StartsWithMessage("Specified argument was out of the range of valid values.");
        }

        [TestCase]
        public void FindMethod_NoMethodFound()
        {
            var classPath = Godot.ProjectSettings.GlobalizePath("res://addons/gdUnit3/test/core/resources/sources/TestPerson.cs");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 5)).IsNull();
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 11)).IsNull();
        }

        [TestCase]
        public void FindMethod_Found()
        {
            var classPath = Godot.ProjectSettings.GlobalizePath("res://addons/gdUnit3/test/core/resources/sources/TestPerson.cs");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 14)).IsEqual("FirstName");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 16)).IsEqual("LastName");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 18)).IsEqual("FullName");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 20)).IsEqual("FullName2");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 22)).IsEqual("FullName3");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 23)).IsEqual("FullName3");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 24)).IsEqual("FullName3");
            AssertString(GdUnitTestSuiteBuilder.FindMethod(classPath, 25)).IsEqual("FullName3");
        }

        [TestCase]
        public void CreateTestSuite()
        {
            var tmp = CreateTempDir("build-test-suite-test");
            string sourceClass = Path.Combine(tmp, "TestPerson.cs");
            File.Copy(Path.GetFullPath(Godot.ProjectSettings.GlobalizePath("res://addons/gdUnit3/test/core/resources/sources/TestPerson.cs")), sourceClass);

            // first time generates the test suite and adds the test case
            string testSuite = Path.Combine(tmp, "TestPersonTest.cs");
            Dictionary<string, object> dictionary = GdUnitTestSuiteBuilder.Build(sourceClass, 24, testSuite);
            AssertThat(dictionary["path"]).IsEqual(testSuite);
            AssertThat((int)dictionary["line"]).IsEqual(16);
            AssertThat(File.ReadAllText(testSuite, Encoding.UTF8)).IsEqual(NewCreatedTestSuite(sourceClass));

            // second call updated the existing test suite and adds a new test case
            dictionary = GdUnitTestSuiteBuilder.Build(sourceClass, 16, testSuite);
            AssertThat(dictionary["path"]).IsEqual(testSuite);
            AssertThat((int)dictionary["line"]).IsEqual(22);
            AssertThat(File.ReadAllText(testSuite, Encoding.UTF8)).IsEqual(UpdatedTestSuite(sourceClass));
        }

        [TestCase]
        public void CreateTestSuite_NoMethodFound()
        {
            var tmp = CreateTempDir("build-test-suite-test");
            string sourceClass = Path.Combine(tmp, "TestPerson.cs");
            File.Copy(Path.GetFullPath(Godot.ProjectSettings.GlobalizePath("res://addons/gdUnit3/test/core/resources/sources/TestPerson.cs")), sourceClass);

            // uning a line number where no method is defined in the source class
            Dictionary<string, object> dictionary = GdUnitTestSuiteBuilder.Build(sourceClass, 4, Path.Combine(tmp, "TestPersonTest.cs"));
            AssertThat(dictionary["error"] as string)
                .StartsWith("Can't parse method name from")
                .EndsWith("app_userdata\\gdUnit3\\tmp\\build-test-suite-test\\TestPerson.cs:4.");
        }


        [TestCase]
        public void CreateTestSuite_TestCaseAlreadyExists()
        {
            var tmp = CreateTempDir("build-test-suite-test");
            string sourceClass = Path.Combine(tmp, "TestPerson.cs");
            File.Copy(Path.GetFullPath(Godot.ProjectSettings.GlobalizePath("res://addons/gdUnit3/test/core/resources/sources/TestPerson.cs")), sourceClass);

            string expected = NewCreatedTestSuite(sourceClass);

            // first time generates the test suite and adds the test case
            string testSuite = Path.Combine(tmp, "TestPersonTest.cs");
            Dictionary<string, object> dictionary = GdUnitTestSuiteBuilder.Build(sourceClass, 24, testSuite);
            AssertThat(dictionary["path"]).IsEqual(testSuite);
            AssertThat((int)dictionary["line"]).IsEqual(16);
            AssertThat(File.ReadAllText(testSuite, Encoding.UTF8)).IsEqual(expected);

            // try to add again the same test case
            dictionary = GdUnitTestSuiteBuilder.Build(sourceClass, 24, testSuite);
            AssertThat(dictionary["path"]).IsEqual(testSuite);
            AssertThat((int)dictionary["line"]).IsEqual(16);
            // the content of the test suite sould not be changed
            AssertThat(File.ReadAllText(testSuite, Encoding.UTF8)).IsEqual(expected);
        }

        private static string UpdatedTestSuite(string sourceClass) =>
@"// GdUnit generated TestSuite
using Godot;
using GdUnit3;

namespace Example.Test.Resources
{
	using static Assertions;
	using static Utils;

	[TestSuite]
	public class TestPersonTest
	{
		// TestSuite generated from
		private const string sourceClazzPath = ${sourceClazzPath};
		[TestCase]
		public void FullName3()
		{
			AssertNotYetImplemented();
		}

		[TestCase]
		public void LastName()
		{
			AssertNotYetImplemented();
		}
	}
}".Replace("${sourceClazzPath}", $"\"{sourceClass}\"");

        private static string NewCreatedTestSuite(string sourceClass) =>
@"// GdUnit generated TestSuite
using Godot;
using GdUnit3;

namespace Example.Test.Resources
{
	using static Assertions;
	using static Utils;

	[TestSuite]
	public class TestPersonTest
	{
		// TestSuite generated from
		private const string sourceClazzPath = ${sourceClazzPath};
		[TestCase]
		public void FullName3()
		{
			AssertNotYetImplemented();
		}
	}
}".Replace("${sourceClazzPath}", $"\"{sourceClass}\"");

    }
}

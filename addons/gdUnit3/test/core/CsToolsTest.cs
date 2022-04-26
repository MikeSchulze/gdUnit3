
using System.IO;

namespace GdUnit3.Core.Tests
{
    using Tools;
    using static Utils;
    using static Assertions;

    [TestSuite]
    public class CsToolsTest
    {

        [TestCase]
        public void CreateTestSuite()
        {
            var tmp = CreateTempDir("build-test-suite-test");
            string sourceClass = Path.Combine(tmp, "TestPerson.cs");
            File.Copy(Path.GetFullPath(Godot.ProjectSettings.GlobalizePath("res://addons/gdUnit3/test/core/resources/sources/TestPerson.cs")), sourceClass);

            // first time generates the test suite and adds the test case
            string path = Path.Combine(tmp, "TestPersonTest.cs");

            string testSuite = Path.Combine(tmp, "TestPersonTest.cs");
            System.Console.WriteLine(Godot.OS.GetUserDataDir());
            Godot.Collections.Dictionary dictionary = CsTools.CreateTestSuite(sourceClass, 24, testSuite);
            AssertThat(dictionary["path"]).IsEqual(testSuite);
            AssertThat((int)dictionary["line"]).IsEqual(16);
        }

    }
}

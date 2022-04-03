
namespace GdUnit3.Tests.Core
{
    using Tools;
    using static Assertions;

    [TestSuite]
    public class CsToolsTest
    {

        [TestCase]
        public void ParseNameSpace()
        {
            AssertString(CsTools.ParseNameSpace("addons/gdUnit3/test/core/resources/testsuites/mono/spaceA/TestSuite.cs")).IsEqual("GdUnit3.Tests.SpaceA");
            AssertString(CsTools.ParseNameSpace("addons/gdUnit3/test/core/resources/testsuites/mono/spaceB/TestSuite.cs")).IsEqual("GdUnit3.Tests.SpaceB");
            // source file not exists
            AssertString(CsTools.ParseNameSpace("addons/gdUnit3/test/core/resources/testsuites/mono/spaceC/TestSuite.cs")).IsNull();
        }

        [TestCase]
        public void ParseType()
        {
            AssertObject(CsTools.ParseType("addons/gdUnit3/test/core/resources/testsuites/mono/spaceA/TestSuite.cs")).IsEqual(typeof(GdUnit3.Tests.SpaceA.TestSuite));
            AssertObject(CsTools.ParseType("addons/gdUnit3/test/core/resources/testsuites/mono/spaceB/TestSuite.cs")).IsEqual(typeof(GdUnit3.Tests.SpaceB.TestSuite));
            // source file not exists
            AssertObject(CsTools.ParseType("addons/gdUnit3/test/core/resources/testsuites/mono/spaceC/TestSuite.cs")).IsNull();
        }

    }
}
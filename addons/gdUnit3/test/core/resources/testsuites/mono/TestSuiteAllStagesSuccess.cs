namespace GdUnit3.Tests.Resources
{
    using static Assertions;

    // will be ignored because of missing `[TestSuite]` anotation
    // used by executor integration test
    public class TestSuiteAllStagesSuccess : TestSuite
    {

        [TestCase]
        public void TestCase1()
        {
            AssertBool(true).IsEqual(true);
        }

        [TestCase]
        public void TestCase2()
        {
            AssertBool(true).IsEqual(true);
        }
    }
}
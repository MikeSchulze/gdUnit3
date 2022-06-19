namespace GdUnit3.Tests.Resource
{
    using static Assertions;
    [TestSuite]
    public class ExampleTestSuiteA
    {

        [TestCase]
        public void TestCase1()
        {
            AssertBool(true).IsEqual(true);
        }

        [TestCase]
        public void TestCase2()
        {
            AssertBool(false).IsEqual(false);
        }
    }
}

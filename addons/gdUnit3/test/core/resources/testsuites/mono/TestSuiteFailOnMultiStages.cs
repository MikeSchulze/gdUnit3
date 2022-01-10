namespace GdUnit3.Tests.Resources
{
    using static Assertions;

    // will be ignored because of missing `[TestSuite]` anotation
    // used by executor integration test
    public class TestSuiteFailOnMultiStages : TestSuite
    {

        [Before]
        public void Before()
        {
            AssertString("Suite Before()").IsEqual("Suite Before()");
        }

        [After]
        public void After()
        {
            AssertString("Suite After()").OverrideFailureMessage("failed on After()").IsEmpty();
        }

        [BeforeTest]
        public void BeforeTest()
        {
            AssertString("Suite BeforeTest()").OverrideFailureMessage("failed on BeforeTest()").IsEmpty();
        }

        [AfterTest]
        public void AfterTest()
        {
            AssertString("Suite AfterTest()").IsEqual("Suite AfterTest()");
        }

        [TestCase]
        public void TestCase1()
        {
            AssertString("TestCase1").IsEmpty();
        }

        [TestCase]
        public void TestCase2()
        {
            AssertString("TestCase2").IsEqual("TestCase2");
        }
    }
}

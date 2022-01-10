namespace GdUnit3.Tests.Resources
{
    using static Assertions;

    // will be ignored because of missing `[TestSuite]` anotation
    // used by executor integration test
    public class TestSuiteFailOnStageBeforeTest : TestSuite
    {

        [Before]
        public void Before()
        {
            AssertString("Suite Before()").IsEqual("Suite Before()");
        }

        [After]
        public void After()
        {
            AssertString("Suite After()").IsEqual("Suite After()");
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
            AssertString("TestCase1").IsEqual("TestCase1");
        }

        [TestCase]
        public void TestCase2()
        {
            AssertString("TestCase2").IsEqual("TestCase2");
        }
    }
}

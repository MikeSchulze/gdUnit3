using GdUnit3;

using static GdUnit3.Assertions;

// will be ignored because of missing `[TestSuite]` anotation
// used by executor integration test
public class TestSuiteFailOnStageBefore : TestSuite
{

    [Before]
    public void Before()
    {
        AssertString("suite before").OverrideFailureMessage("failed on before()").IsEmpty();
    }

    [After]
    public void After()
    {
        AssertString("suite after").IsEqual("suite after");
    }

    [BeforeTest]
    public void BeforeTest()
    {
        AssertString("test before").IsEqual("test before");
    }

    [AfterTest]
    public void AfterTest()
    {
        AssertString("test after").IsEqual("test after");
    }

    [TestCase]
    public void TestCase1()
    {
        AssertString("test_case1").IsEqual("test_case1");
    }

    [TestCase]
    public void TestCase2()
    {
        AssertString("test_case2").IsEqual("test_case2");
    }

}

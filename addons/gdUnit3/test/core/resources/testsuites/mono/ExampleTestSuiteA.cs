using GdUnit3;

using static GdUnit3.Assertions;

// will be ignored because of missing `[TestSuite]` anotation
// used by executor integration test
public class ExampleTestSuiteA : TestSuite
{

    [TestCase]
    public void TestCase1()
    {
        AssertBool(true).IsEqual(false);
    }

    [TestCase]
    public void TestCase2()
    {
        AssertBool(true).IsEqual(false);
    }

    [IgnoreUntil("This test is set to ignore")]
    [TestCase]
    public void Ignored()
    {
    }
}

using GdUnit3;

using static GdUnit3.Assertions;

// will be ignored because of missing `[TestSuite]` anotation
public class NotATestSuite : TestSuite
{

    [TestCase]
    public void TestFoo()
    {
        AssertBool(true).IsEqual(false);
    }
}
using Godot;
using GdUnit3;

// will be ignored because of missing `[TestSuite]` anotation
public class NotATestSuite : TestSuite
{

    [TestCase]
    public void TestFoo()
    {
        AssertBool(true).IsEqual(false);
    }
}

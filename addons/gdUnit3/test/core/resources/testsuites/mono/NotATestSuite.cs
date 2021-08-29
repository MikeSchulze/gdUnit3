using Godot;
using GdUnit3;

// will be ignored becaus of missing `[TestSuite]` animation
public class NotATestSuite : TestSuite
{

    [TestCase]
    public void TestFoo()
    {
        AssertBool(true).IsEqual(false);
    }
}

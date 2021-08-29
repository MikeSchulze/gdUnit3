using Godot;
using GdUnit3;


[TestSuite]
public class ExampleTest : TestSuite
{
    [Before]
    public void Before()
    {
        GD.PrintS("calling Before");
    }

    [After]
    public void After()
    {
        GD.PrintS("calling After");
    }

    [BeforeTest]
    public void BeforeTest()
    {
        GD.PrintS("calling BeforeTest");
    }

    [AfterTest]
    public void AfterTest()
    {
        GD.PrintS("calling AfterTest");
    }

    [TestCase]
    public void TestFoo()
    {
        AssertBool(true).IsEqual(true);
    }

    [TestCase]
    public void TestBar()
    {
        AssertBool(true).IsEqual(true);
    }

}

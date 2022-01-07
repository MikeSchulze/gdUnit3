using System.Threading.Tasks;
using GdUnit3;

using static GdUnit3.Assertions;

// will be ignored because of missing `[TestSuite]` anotation
// used by executor integration test
[TestSuite]
public class TestSuiteAbortOnTestTimeout : TestSuite
{

    [Before]
    public async Task Before()
    {
        // we await 1s and continue, this stage should be processed successfully (no timeout) 
        System.Diagnostics.Stopwatch stopwatch = new System.Diagnostics.Stopwatch();
        stopwatch.Start();
        await ToSignal(GetTree().CreateTimer(1.0f), "timeout");
        stopwatch.Stop();
    }

    [After]
    public void After()
    { }

    [BeforeTest]
    public void BeforeTest()
    { }

    [AfterTest]
    public void AfterTest()
    { }

    [TestCase(Timeout = 1000, Description = "This test will be interrupted after a timout of 1000ms.")]
    public async Task TestCase1()
    {
        AssertBool(true).IsEqual(true);
        System.Diagnostics.Stopwatch stopwatch = new System.Diagnostics.Stopwatch();
        stopwatch.Start();
        // we wait 2s and expect an interuption after 1s
        await ToSignal(GetTree().CreateTimer(2.0f), "timeout");
        // this line will not be called because of test timeout interrupt after 2s
        stopwatch.Stop();
        AssertBool(true).OverrideFailureMessage($"Expected test is interuppted after 1000ms but is runs {stopwatch.ElapsedMilliseconds}ms").IsFalse();
    }

    [TestCase(Timeout = 4000, Description = "This test will end with a failure, no timeout.")]
    public async Task TestCase2()
    {
        await ToSignal(GetTree().CreateTimer(1.0f), "timeout");
        AssertBool(true).IsEqual(false);
    }

    [TestCase(Timeout = 4000, Description = "This test will end with a success, no timeout.")]
    public async Task TestCase3()
    {
        await ToSignal(GetTree().CreateTimer(1.0f), "timeout");
        AssertBool(true).IsEqual(true);
    }

    [TestCase(Timeout = 4000, Description = "This test has a invalid signature and should be end with a warning. `public async Task TestCase4()`")]
    public async void TestCase4()
    {
        AssertBool(true).IsEqual(true);
    }

    [TestCase(Description = "This test has no timeout definition, expect to end with success.")]
    public void TestCase5()
    {
        AssertBool(true).IsEqual(true);
    }
}

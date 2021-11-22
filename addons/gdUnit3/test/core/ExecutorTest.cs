using System.Collections.Generic;


using Godot;
using GdUnit3;


[TestSuite]
public class ExecutorTest : TestSuite, ITestEventListener
{
    private Executor _executor;
    private List<TestEvent> _events = new List<TestEvent>();


    [Before]
    public void Before()
    {
        _executor = new Executor();
        _executor.AddGdTestEventListener(this);
    }

    private TestSuite LoadTestSuite(string resourcePath)
    {
        TestSuite testSuite = ResourceLoader.Load(resourcePath).Call("new") as TestSuite;
        testSuite.Name = testSuite.ResourcePath.GetFile().Replace(".cs", "");

        foreach (TestCase testCase in CsTools.GetTestCases(testSuite.Name))
        {
            Godot.Collections.Dictionary attributes = testCase.attributes();
            var test = new Godot.Node();
            test.Name = attributes["name"] as string;
            testSuite.AddChild(test);
        }
        return testSuite;
    }


    public void PublishEvent(TestEvent e) => _events.Add(e);

    private List<TestEvent> Execute(TestSuite testSuite, bool enableOrphanDetection = true)
    {
        _events.Clear();
        // _executor._memory_pool.configure(enable_orphan_detection)
        _executor.Execute(testSuite);
        return _events;
    }


    private readonly string[] DEFAULT_TEST_CASES = { "TestCase1", "TestCase2" };
    private void AssertEventList(List<TestEvent> events, string suiteName, string[] testCaseNames = null)
    {
        var testCases = testCaseNames ?? DEFAULT_TEST_CASES;

    }

    [TestCase]
    public void test_execute_success()
    {
        TestSuite testSuite = LoadTestSuite("res://addons/gdUnit3/test/core/resources/testsuites/mono/ExampleTestSuiteA.cs");
        // verify all test cases loaded
        //AssertArray(testSuite.get_children()).extract("get_name").contains_exactly(["TestCase1", "TestCase2"]);
        // # simulate test suite execution
        var events = Execute(testSuite);
        events.ForEach(e => Godot.GD.PrintS(e));
        // verify basis infos
        AssertEventList(events, "NotATestSuite");



    }

}

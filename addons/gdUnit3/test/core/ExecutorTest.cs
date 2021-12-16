using System;
using System.Collections.Generic;
using System.Threading;

using GdUnit3;

using static GdUnit3.Assertions;


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
        TestSuite testSuite = Godot.ResourceLoader.Load(resourcePath).Call("new") as TestSuite;
        testSuite.Name = testSuite.GetType().FullName;

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
        var savedTestInstance = Thread.GetData(Thread.GetNamedDataSlot("TestInstance"));
        try
        {
            _events.Clear();
            // _executor._memory_pool.configure(enable_orphan_detection)
            _executor.Execute(testSuite);
            return _events;
        }
        finally
        {
            Thread.SetData(Thread.GetNamedDataSlot("TestInstance"), savedTestInstance);
        }
    }


    private readonly string[] DEFAULT_TEST_CASES = { "TestCase1", "TestCase2" };
    private void AssertEventList(List<TestEvent> events, string suiteName, string[] testCaseNames = null)
    {
        events.ForEach(e => Godot.GD.PrintS(e));

        var testCases = testCaseNames ?? DEFAULT_TEST_CASES;
        var expectedEvents = new List<ITuple>();

        expectedEvents.Add(Tuple(TestEvent.TYPE.TESTSUITE_BEFORE, suiteName, "", testCases.Length));
        foreach (var testCase in testCases)
        {
            expectedEvents.Add(Tuple(TestEvent.TYPE.TESTCASE_BEFORE, suiteName, testCase, 0));
            expectedEvents.Add(Tuple(TestEvent.TYPE.TESTCASE_AFTER, suiteName, testCase, 0));
        }
        expectedEvents.Add(Tuple(TestEvent.TYPE.TESTSUITE_AFTER, suiteName, "", 0));

        AssertArray(events)
            .HasSize(6)
            .ExtractV(Extr("Type"), Extr("SuiteName"), Extr("TestName"), Extr("TotalCount"))
            .ContainsExactly(expectedEvents);
    }

    [TestCase]
    public void Execute_Success()
    {
        TestSuite testSuite = LoadTestSuite("res://addons/gdUnit3/test/core/resources/testsuites/mono/ExampleTestSuiteA.cs");
        // verify all test cases loaded
        AssertArray(testSuite.GetChildren()).Extract("GetName").ContainsExactly(new string[] { "TestCase1", "TestCase2" });
        // # simulate test suite execution
        var events = Execute(testSuite);

        // verify basis infos
        AssertEventList(events, "ExampleTestSuiteA");



    }

}

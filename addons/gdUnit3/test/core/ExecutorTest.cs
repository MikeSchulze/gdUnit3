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

    private void AssertEventList(List<TestEvent> events, string suiteName, params string[] testCaseNames)
    {
        var expectedEvents = new List<ITuple>();

        expectedEvents.Add(Tuple(TestEvent.TYPE.TESTSUITE_BEFORE, suiteName, "", testCaseNames.Length));
        foreach (var testCase in testCaseNames)
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

    private IArrayAssert AssertEventCounters(List<TestEvent> events) =>
        AssertArray(events).ExtractV(Extr("Type"), Extr("ErrorCount"), Extr("FailedCount"), Extr("OrphanCount"));

    private IArrayAssert AssertEventStates(List<TestEvent> events) =>
         AssertArray(events).ExtractV(Extr("TestName"), Extr("IsSuccess"), Extr("IsWarning"), Extr("IsFailed"), Extr("IsError"));


    [TestCase]
    public void Execute_Success()
    {
        TestSuite testSuite = LoadTestSuite("res://addons/gdUnit3/test/core/resources/testsuites/mono/ExampleTestSuiteA.cs");
        // verify all test cases loaded
        AssertArray(testSuite.GetChildren()).Extract("GetName").ContainsExactly(new string[] { "TestCase1", "TestCase2" });
        // # simulate test suite execution
        var events = Execute(testSuite);

        // verify basis infos
        AssertEventList(events, "ExampleTestSuiteA", "TestCase1", "TestCase2");

        AssertEventCounters(events).ContainsExactly(
            Tuple(TestEvent.TYPE.TESTSUITE_BEFORE, 0, 0, 0),
            Tuple(TestEvent.TYPE.TESTCASE_BEFORE, 0, 0, 0),
            Tuple(TestEvent.TYPE.TESTCASE_AFTER, 0, 0, 0),
            Tuple(TestEvent.TYPE.TESTCASE_BEFORE, 0, 0, 0),
            Tuple(TestEvent.TYPE.TESTCASE_AFTER, 0, 0, 0),
            Tuple(TestEvent.TYPE.TESTSUITE_AFTER, 0, 0, 0)
        );
        AssertEventStates(events).ContainsExactly(
            Tuple("before", true, false, false, false),
            Tuple("TestCase1", true, false, false, false),
            Tuple("TestCase1", true, false, false, false),
            Tuple("TestCase2", true, false, false, false),
            Tuple("TestCase2", true, false, false, false),
            Tuple("after", true, false, false, false)
        );
    }

}

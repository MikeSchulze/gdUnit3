using System.Collections.Generic;
using System.Threading;

using GdUnit3;

using static GdUnit3.Assertions;
using static GdUnit3.TestEvent.TYPE;
using static GdUnit3.TestReport.TYPE;


[TestSuite]
public class ExecutorTest : TestSuite, ITestEventListener
{
    private Executor _executor;
    private List<TestEvent> _events = new List<TestEvent>();

    private bool _verbose = false;


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


    public void PublishEvent(TestEvent e)
    {
        if (_verbose)
        {
            Godot.GD.PrintS("-------------------------------");
            Godot.GD.PrintS(e.Type, e.SuiteName, e.TestName, new Godot.Collections.Dictionary(e.Statistics));
            Godot.GD.PrintS("ErrorCount:", e.ErrorCount, "FailedCount:", e.FailedCount, "OrphanCount:", e.OrphanCount);
        }
        _events.Add(e);
    }

    private List<TestEvent> Execute(TestSuite testSuite, bool enableOrphanDetection = true)
    {
        _events.Clear();
        _executor.Execute(testSuite);
        return _events;
    }

    private List<ITuple> ExpectedEvents(List<TestEvent> events, string suiteName, params string[] testCaseNames)
    {
        var expectedEvents = new List<ITuple>();

        expectedEvents.Add(Tuple(TESTSUITE_BEFORE, suiteName, "Before", testCaseNames.Length));
        foreach (var testCase in testCaseNames)
        {
            expectedEvents.Add(Tuple(TESTCASE_BEFORE, suiteName, testCase, 0));
            expectedEvents.Add(Tuple(TESTCASE_AFTER, suiteName, testCase, 0));
        }
        expectedEvents.Add(Tuple(TESTSUITE_AFTER, suiteName, "After", 0));
        return expectedEvents;
    }

    private IArrayAssert AssertTestCaseNames(List<TestEvent> events) =>
        AssertArray(events).ExtractV(Extr("Type"), Extr("SuiteName"), Extr("TestName"), Extr("TotalCount"));

    private IArrayAssert AssertEventCounters(List<TestEvent> events) =>
        AssertArray(events).ExtractV(Extr("Type"), Extr("TestName"), Extr("ErrorCount"), Extr("FailedCount"), Extr("OrphanCount"));

    private IArrayAssert AssertEventStates(List<TestEvent> events) =>
         AssertArray(events).ExtractV(Extr("Type"), Extr("TestName"), Extr("IsSuccess"), Extr("IsWarning"), Extr("IsFailed"), Extr("IsError"));


    private IArrayAssert AssertReports(List<TestEvent> events)
    {
        var extractedEvents = events.ConvertAll(e =>
        {
            var reports = new List<TestReport>(e.Reports).ConvertAll(r => new TestReport(r.Type, r.LineNumber, NormalizedFailureMessage(r.Message)));
            if (_verbose)
                reports.ForEach(r => Godot.GD.PrintS("Reports ->", r));
            return new { e.TestName, EventType = e.Type, Reports = reports };
        });
        return AssertArray(extractedEvents).ExtractV(Extr("EventType"), Extr("TestName"), Extr("Reports"));
    }

    private static string NormalizedFailureMessage(string input)
    {
        using (var rtl = new Godot.RichTextLabel())
        {
            rtl.BbcodeEnabled = true;
            rtl.ParseBbcode(input);
            var text = rtl.Text;
            rtl.Free();
            return text.Replace("\n", "").Replace("\r", "");
        }
    }


    [TestCase]
    public void Execute_Success()
    {
        TestSuite testSuite = LoadTestSuite("res://addons/gdUnit3/test/core/resources/testsuites/mono/TestSuiteAllStagesSuccess.cs");
        // verify all test cases loaded
        AssertArray(testSuite.GetChildren()).Extract("GetName").ContainsExactly(new string[] { "TestCase1", "TestCase2" });
        // # simulate test suite execution
        var events = Execute(testSuite);

        // verify basis infos
        AssertTestCaseNames(events)
            .ContainsExactly(ExpectedEvents(events, "TestSuiteAllStagesSuccess", "TestCase1", "TestCase2"));

        AssertEventCounters(events).ContainsExactly(
            Tuple(TESTSUITE_BEFORE, "Before", 0, 0, 0),
            Tuple(TESTCASE_BEFORE, "TestCase1", 0, 0, 0),
            Tuple(TESTCASE_AFTER, "TestCase1", 0, 0, 0),
            Tuple(TESTCASE_BEFORE, "TestCase2", 0, 0, 0),
            Tuple(TESTCASE_AFTER, "TestCase2", 0, 0, 0),
            Tuple(TESTSUITE_AFTER, "After", 0, 0, 0)
        );
        AssertEventStates(events).ContainsExactly(
            Tuple(TESTSUITE_BEFORE, "Before", true, false, false, false),
            Tuple(TESTCASE_BEFORE, "TestCase1", true, false, false, false),
            Tuple(TESTCASE_AFTER, "TestCase1", true, false, false, false),
            Tuple(TESTCASE_BEFORE, "TestCase2", true, false, false, false),
            Tuple(TESTCASE_AFTER, "TestCase2", true, false, false, false),
            Tuple(TESTSUITE_AFTER, "After", true, false, false, false)
        );

        // all success no reports expected
        AssertReports(events).ContainsExactly(
            Tuple(TESTSUITE_BEFORE, "Before", new List<TestReport>()),
            Tuple(TESTCASE_BEFORE, "TestCase1", new List<TestReport>()),
            Tuple(TESTCASE_AFTER, "TestCase1", new List<TestReport>()),
            Tuple(TESTCASE_BEFORE, "TestCase2", new List<TestReport>()),
            Tuple(TESTCASE_AFTER, "TestCase2", new List<TestReport>()),
            Tuple(TESTSUITE_AFTER, "After", new List<TestReport>()));
    }

    [TestCase]
    public void Execute_FailureOnStage_Before()
    {
        TestSuite testSuite = LoadTestSuite("res://addons/gdUnit3/test/core/resources/testsuites/mono/TestSuiteFailOnStageBefore.cs");
        // verify all test cases loaded
        AssertArray(testSuite.GetChildren()).Extract("GetName").ContainsExactly(new string[] { "TestCase1", "TestCase2" });
        // simulate test suite execution
        var events = Execute(testSuite);
        // verify basis infos
        AssertTestCaseNames(events)
            .ContainsExactly(ExpectedEvents(events, "TestSuiteFailOnStageBefore", "TestCase1", "TestCase2"));

        // we expect the testsuite is failing on stage 'before()' and commits one failure
        // where is reported finally at TESTSUITE_AFTER event
        AssertEventCounters(events).ContainsExactly(
            Tuple(TESTSUITE_BEFORE, "Before", 0, 0, 0),
            Tuple(TESTCASE_BEFORE, "TestCase1", 0, 0, 0),
            Tuple(TESTCASE_AFTER, "TestCase1", 0, 0, 0),
            Tuple(TESTCASE_BEFORE, "TestCase2", 0, 0, 0),
            Tuple(TESTCASE_AFTER, "TestCase2", 0, 0, 0),
            // report failure failed_count = 1
            Tuple(TESTSUITE_AFTER, "After", 0, 1, 0)
        );
        AssertEventStates(events).ContainsExactly(
            Tuple(TESTSUITE_BEFORE, "Before", true, false, false, false),
            Tuple(TESTCASE_BEFORE, "TestCase1", true, false, false, false),
            Tuple(TESTCASE_AFTER, "TestCase1", true, false, false, false),
            Tuple(TESTCASE_BEFORE, "TestCase2", true, false, false, false),
            Tuple(TESTCASE_AFTER, "TestCase2", true, false, false, false),
            // report suite is not success, is failed
            Tuple(TESTSUITE_AFTER, "After", false, false, true, false)
        );

        AssertReports(events).ContainsExactly(
            Tuple(TESTSUITE_BEFORE, "Before", new List<TestReport>()),
            Tuple(TESTCASE_BEFORE, "TestCase1", new List<TestReport>()),
            Tuple(TESTCASE_AFTER, "TestCase1", new List<TestReport>()),
            Tuple(TESTCASE_BEFORE, "TestCase2", new List<TestReport>()),
            Tuple(TESTCASE_AFTER, "TestCase2", new List<TestReport>()),
            Tuple(TESTSUITE_AFTER, "After", new List<TestReport>() { new TestReport(FAILURE, 13, "failed on before()") }));
    }

}

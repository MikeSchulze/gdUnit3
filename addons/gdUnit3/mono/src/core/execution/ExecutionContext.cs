using System;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

using GdUnit3.Executions.Monitors;

namespace GdUnit3.Executions
{
    internal sealed class ExecutionContext : IDisposable
    {
        public ExecutionContext(TestSuite testInstance, IEnumerable<ITestEventListener> eventListeners, bool reportOrphanNodesEnabled)
        {
            Thread.SetData(Thread.GetNamedDataSlot("ExecutionContext"), this);
            MemoryPool = new MemoryPool();
            OrphanMonitor = new OrphanNodesMonitor(reportOrphanNodesEnabled);
            Stopwatch = new Stopwatch();
            Stopwatch.Start();

            ReportOrphanNodesEnabled = reportOrphanNodesEnabled;
            FailureReporting = true;
            TestSuite = testInstance;
            EventListeners = eventListeners;
            ReportCollector = new TestReportCollector();
            SubExecutionContexts = new List<ExecutionContext>();
            Disposables = new List<IDisposable>();
        }
        public ExecutionContext(ExecutionContext context) : this(context.TestSuite, context.EventListeners, context.ReportOrphanNodesEnabled)
        {
            ReportCollector = context.ReportCollector;
            context.SubExecutionContexts.Add(this);
            CurrentTestCase = context.CurrentTestCase ?? null;
            IsSkipped = CurrentTestCase?.IsSkipped ?? false;
            CurrentIteration = CurrentTestCase?.Attributes.Iterations ?? 0;
        }

        public ExecutionContext(ExecutionContext context, TestCase testCase) : this(context.TestSuite, context.EventListeners, context.ReportOrphanNodesEnabled)
        {
            context.SubExecutionContexts.Add(this);
            CurrentTestCase = testCase;
            CurrentIteration = testCase.Attributes.Iterations;
            IsSkipped = CurrentTestCase.IsSkipped;
        }

        public bool ReportOrphanNodesEnabled
        { get; private set; }

        public bool FailureReporting
        { get; set; }

        public OrphanNodesMonitor OrphanMonitor
        { get; set; }

        public MemoryPool MemoryPool
        { get; set; }

        public Stopwatch Stopwatch
        { get; private set; }

        public TestSuite TestSuite
        { get; private set; }

        private List<IDisposable> Disposables
        { get; set; }

        public static ExecutionContext? Current => Thread.GetData(Thread.GetNamedDataSlot("ExecutionContext")) as ExecutionContext;

        private IEnumerable<ITestEventListener> EventListeners
        { get; set; }

        private List<ExecutionContext> SubExecutionContexts
        { get; set; }

        public TestCase? CurrentTestCase
        { get; set; }


        private long Duration => Stopwatch.ElapsedMilliseconds;

        private int _iteration;
        public int CurrentIteration
        {
            get => _iteration--;
            set => _iteration = value;
        }

        public TestReportCollector ReportCollector
        { get; private set; }

        public bool IsFailed => ReportCollector.Failures.Any() || SubExecutionContexts.Where(context => context.IsFailed).Any();

        public bool IsError => ReportCollector.Errors.Any() || SubExecutionContexts.Where(context => context.IsError).Any();

        public bool IsWarning => ReportCollector.Warnings.Any() || SubExecutionContexts.Where(context => context.IsWarning).Any();

        public bool IsSkipped
        { get; private set; }

        public IEnumerable<TestReport> CollectReports => ReportCollector.Reports;

        private int SkippedCount => SubExecutionContexts.Where(context => context.IsSkipped).Count();

        private int FailureCount => ReportCollector.Failures.Count();

        private int ErrorCount => ReportCollector.Errors.Count();

        public int OrphanCount(bool recursive)
        {
            var orphanCount = OrphanMonitor.OrphanCount;
            if (recursive)
                orphanCount += SubExecutionContexts.Select(context => context.OrphanMonitor.OrphanCount).Sum();
            return orphanCount;
        }

        public IDictionary BuildStatistics(int orphanCount)
        {
            return TestEvent.BuildStatistics(
                orphanCount,
                IsError, ErrorCount,
                IsFailed, FailureCount,
                IsWarning,
                IsSkipped, SkippedCount,
                Duration);
        }

        public void FireTestEvent(TestEvent e) =>
            EventListeners.ToList().ForEach(l => l.PublishEvent(e));

        public void FireBeforeEvent() =>
            FireTestEvent(TestEvent.Before(TestSuite.ResourcePath, TestSuite.Name, TestSuite.TestCaseCount));

        public void FireAfterEvent() =>
            FireTestEvent(TestEvent.After(TestSuite.ResourcePath, TestSuite.Name, BuildStatistics(OrphanCount(false)), CollectReports));

        public void FireBeforeTestEvent() =>
            FireTestEvent(TestEvent.BeforeTest(TestSuite.ResourcePath, TestSuite.Name, CurrentTestCase?.Name ?? "Unknown"));

        public void FireAfterTestEvent() =>
            FireTestEvent(TestEvent.AfterTest(TestSuite.ResourcePath, TestSuite.Name, CurrentTestCase?.Name ?? "Unknown", BuildStatistics(OrphanCount(true)), CollectReports));


        public static void RegisterDisposable(IDisposable disposable) =>
            ExecutionContext.Current?.Disposables.Add(disposable);

        public void Dispose()
        {
            Disposables.ForEach(disposable => disposable.Dispose());
            Stopwatch.Stop();
        }

        public void PrintDebug(string name = "")
        {
            Godot.GD.PrintS(name, "test context", TestSuite.Name, CurrentTestCase?.Name, "error:" + IsError, "failed:" + IsFailed, "skipped:" + IsSkipped);
        }
    }

}

using System;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

namespace GdUnit3
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
            TestInstance = testInstance;
            EventListeners = eventListeners;
            ReportCollector = new TestReportCollector();
            SubExecutionContexts = new List<ExecutionContext>();
            // fake report consumer for now, will be replaced by TestEvent listener
            testInstance.SetMeta("gdunit.report.consumer", ReportCollector);
        }
        public ExecutionContext(ExecutionContext context) : this(context.TestInstance, context.EventListeners, context.ReportOrphanNodesEnabled)
        {
            ReportCollector = context.ReportCollector;
            context.SubExecutionContexts.Add(this);
            CurrentTestCase = context.CurrentTestCase ?? null;
            IsSkipped = CurrentTestCase?.Skipped ?? false;
            CurrentIteration = CurrentTestCase?.Attributes.Iterations ?? 0;
        }

        public ExecutionContext(ExecutionContext context, TestCase testCase) : this(context.TestInstance, context.EventListeners, context.ReportOrphanNodesEnabled)
        {
            context.SubExecutionContexts.Add(this);
            CurrentTestCase = testCase;
            CurrentIteration = testCase.Attributes.Iterations;
            IsSkipped = CurrentTestCase.Skipped;
        }

        public bool ReportOrphanNodesEnabled { get; private set; }
        public bool FailureReporting { get; set; }

        public OrphanNodesMonitor OrphanMonitor
        { get; set; }

        public MemoryPool MemoryPool
        { get; set; }


        public Stopwatch Stopwatch
        { get; private set; }

        public TestSuite TestInstance
        { get; private set; }

        public static ExecutionContext Current => Thread.GetData(Thread.GetNamedDataSlot("ExecutionContext")) as ExecutionContext;

        private IEnumerable<ITestEventListener> EventListeners
        { get; set; }

#nullable enable
        private List<ExecutionContext> SubExecutionContexts
        { get; set; }

        public TestCase? CurrentTestCase
        { get; set; }
#nullable disable

        private long Duration
        { get => Stopwatch.ElapsedMilliseconds; }

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
            FireTestEvent(TestEvent.Before(TestInstance.ResourcePath, TestInstance.Name, TestInstance.TestCaseCount));

        public void FireAfterEvent() =>
            FireTestEvent(TestEvent.After(TestInstance.ResourcePath, TestInstance.Name, BuildStatistics(OrphanCount(false)), CollectReports));

        public void FireBeforeTestEvent() =>
            FireTestEvent(TestEvent.BeforeTest(TestInstance.ResourcePath, TestInstance.Name, CurrentTestCase.Name));

        public void FireAfterTestEvent() =>
            FireTestEvent(TestEvent.AfterTest(TestInstance.ResourcePath, TestInstance.Name, CurrentTestCase.Name, BuildStatistics(OrphanCount(true)), CollectReports));

        public void Dispose()
        {
            Stopwatch.Stop();
        }

        public void PrintDebug(string name = "")
        {
            Godot.GD.PrintS(name, "test context", TestInstance.Name, CurrentTestCase?.Name, "error:" + IsError, "failed:" + IsFailed, "skipped:" + IsSkipped);
        }
    }

}

using System;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace GdUnit3
{
    public sealed class ExecutionContext : IDisposable
    {
        public ExecutionContext(TestSuite testInstance, IEnumerable<ITestEventListener> eventListeners)
        {
            OrphanMonitor = new OrphanNodesMonitor();
            Stopwatch = new Stopwatch();
            Stopwatch.Start();

            TestInstance = testInstance;
            EventListeners = eventListeners;
            ReportCollector = new TestReportCollector();
            SubExecutionContexts = new List<ExecutionContext>();
            // fake report consumer for now, will be replaced by TestEvent listener
            testInstance.SetMeta("gdunit.report.consumer", ReportCollector);
        }
        public ExecutionContext(ExecutionContext context) : this(context.TestInstance, context.EventListeners)
        {
            context.SubExecutionContexts.Add(this);
            Test = context.Test ?? null;
            Skipped = Test?.Skipped ?? false;
            CurrentIteration = Test?.Attributes.iterations ?? 0;
        }

        public ExecutionContext(ExecutionContext context, TestCase testCase) : this(context.TestInstance, context.EventListeners)
        {
            context.SubExecutionContexts.Add(this);
            Test = testCase;
            CurrentIteration = testCase.Attributes.iterations;
            Skipped = Test.Skipped;
        }

        public OrphanNodesMonitor OrphanMonitor
        { get; set; }

        public Stopwatch Stopwatch
        { get; private set; }

        public TestSuite TestInstance
        { get; private set; }

        private IEnumerable<ITestEventListener> EventListeners
        { get; set; }

#nullable enable
        private List<ExecutionContext> SubExecutionContexts
        { get; set; }
#nullable disable

        public TestCase Test
        { get; set; }

        private bool Skipped
        { get; set; }

        private int Duration
        { get => (int)Stopwatch.ElapsedMilliseconds; }

        private int _iteration;
        public int CurrentIteration
        {
            get => _iteration--;
            set => _iteration = value;
        }

        public TestReportCollector ReportCollector
        { get; private set; }


        public bool IsFailed()
        {
            return ReportCollector.Failures.Count() > 0 || SubExecutionContexts.Where(context => context.IsFailed()).Count() != 0;
        }

        public bool IsError()
        {
            return ReportCollector.Errors.Count() > 0 || SubExecutionContexts.Where(context => context.IsError()).Count() != 0;
        }

        public bool IsWarning()
        {
            return ReportCollector.Warnings.Count() > 0 || SubExecutionContexts.Where(context => context.IsWarning()).Count() != 0;
        }

        public bool IsSkipped() => Skipped;

        private int SkippedCount() => SubExecutionContexts.Where(context => context.IsSkipped()).Count();

        private int FailureCount() => ReportCollector.Failures.Count();

        private int ErrorCount() => ReportCollector.Errors.Count();

        public int OrphanCount() => SubExecutionContexts.Select(context => context.OrphanMonitor.OrphanCount()).Sum();

        public IEnumerable BuildStatistics()
        {
            return TestEvent.BuildStatistics(
                OrphanCount(),
                IsError(), ErrorCount(),
                IsFailed(), FailureCount(),
                false,
                IsSkipped(), SkippedCount(),
                Duration);
        }

        public void FireTestEvent(TestEvent e)
        {
            EventListeners.ToList()
                .ForEach(l => l.PublishEvent(e));
        }

        public void FireBeforeEvent()
        {
            FireTestEvent(TestEvent.Before(TestInstance.ResourcePath, TestInstance.Name, TestInstance.TestCaseCount));
        }

        public void FireAfterEvent()
        {
            FireTestEvent(TestEvent.After(TestInstance.ResourcePath, TestInstance.Name, BuildStatistics()));
        }

        public void FireBeforeTestEvent()
        {
            FireTestEvent(TestEvent.BeforeTest(TestInstance.ResourcePath, TestInstance.Name, Test.Name));
        }

        public void FireAfterTestEvent()
        {
            var testEvent = TestEvent.AfterTest(TestInstance.ResourcePath, TestInstance.Name, Test.Name, BuildStatistics(), ReportCollector.Reports);
            FireTestEvent(testEvent);
        }

        public void Dispose()
        {
            ReportCollector.Clear();
            SubExecutionContexts.Clear();
            Stopwatch.Stop();
        }

        public void PrintDebug(string name = "")
        {
            Godot.GD.PrintS(name, "test context", TestInstance.Name, Test?.Name, "error:" + IsError(), "failed:" + IsFailed(), "skipped:" + IsSkipped());
        }
    }

}

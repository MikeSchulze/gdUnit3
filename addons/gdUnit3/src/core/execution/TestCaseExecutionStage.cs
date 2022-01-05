using System;
using System.Threading;
using System.Reflection;

namespace GdUnit3
{
    public sealed class TestCaseExecutionStage : ExecutionStage<TestCaseAttribute>
    {
        public TestCaseExecutionStage(Type type) : base("TestCases", type)
        { }

        public override void Execute(ExecutionContext context)
        {
            context.MemoryPool.SetActive(StageName());
            context.OrphanMonitor.Start(true);

            while (!context.IsSkipped && context.CurrentIteration > 0)
            {
                base.Execute(context);
            }

            context.MemoryPool.ReleaseRegisteredObjects();
            context.OrphanMonitor.Stop();

            if (context.OrphanMonitor.OrphanCount > 0)
                context.ReportCollector.PushFront(new TestReport(TestReport.TYPE.WARN, context.CurrentTestCase.Attributes.Line, ReportOrphans(context)));
        }

        private static string ReportOrphans(ExecutionContext context) =>
            String.Format("{0}\n Detected <{1}> orphan nodes during test execution!",
                AssertFailures.FormatValue("WARNING:", AssertFailures.WARN_COLOR, false),
                context.OrphanMonitor.OrphanCount);

        protected override void Invoke(ExecutionContext context) => context.CurrentTestCase.MethodInfo.Invoke(context.TestInstance, context.CurrentTestCase.Arguments);
    }
}

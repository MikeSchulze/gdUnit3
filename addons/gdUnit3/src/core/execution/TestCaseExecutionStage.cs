using System;
using System.Threading.Tasks;

using GdUnit3.Asserts;

namespace GdUnit3.Executions
{
    internal sealed class TestCaseExecutionStage : ExecutionStage<TestCaseAttribute>
    {
        public TestCaseExecutionStage() : base("TestCases")
        { }

        public override async Task Execute(ExecutionContext context)
        {
            InitExecutionAttributes(context.CurrentTestCase.MethodInfo);

            context.MemoryPool.SetActive(StageName());
            context.OrphanMonitor.Start(true);
            while (!context.IsSkipped && context.CurrentIteration > 0)
            {
                MethodArguments = context.CurrentTestCase.Arguments;
                await base.Execute(context);
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
    }
}

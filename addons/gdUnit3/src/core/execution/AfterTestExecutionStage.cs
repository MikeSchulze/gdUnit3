using System;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

using GdUnit3.Asserts;

namespace GdUnit3.Executions
{
    internal class AfterTestExecutionStage : ExecutionStage<AfterTestAttribute>
    {
        public AfterTestExecutionStage(TestSuite testSuite) : base("AfterTest", testSuite.Instance.GetType())
        { }

        public override async Task Execute(ExecutionContext context)
        {
            if (!context.IsSkipped)
            {
                context.MemoryPool.SetActive(StageName());
                context.OrphanMonitor.Start();
                await base.Execute(context);
                context.MemoryPool.ReleaseRegisteredObjects();
                context.OrphanMonitor.Stop();
                if (context.OrphanMonitor.OrphanCount > 0)
                    context.ReportCollector.PushFront(new TestReport(TestReport.TYPE.WARN, 0, ReportOrphans(context)));
            }
            context.FireAfterTestEvent();
        }

        private static TestStageAttribute? AfterTestAttribute(ExecutionContext context) => context.TestSuite.Instance
            .GetType()
            .GetMethods()
            .FirstOrDefault(m => m.IsDefined(typeof(AfterTestAttribute)))
            ?.GetCustomAttribute<AfterTestAttribute>();

        private static TestStageAttribute? BeforeTestAttribute(ExecutionContext context) => context.TestSuite.Instance
            .GetType()
            .GetMethods()
            .FirstOrDefault(m => m.IsDefined(typeof(BeforeTestAttribute)))
            ?.GetCustomAttribute<BeforeTestAttribute>();

        private static string ReportOrphans(ExecutionContext context)
        {
            var beforeAttribute = BeforeTestAttribute(context);
            var afterAttributes = AfterTestAttribute(context);
            if (beforeAttribute != null && afterAttributes != null)
                return String.Format("{0}\n Detected <{1}> orphan nodes during test setup stage!\n Check [b]{2}[/b] and [b]{3}[/b] for unfreed instances!",
                    AssertFailures.FormatValue("WARNING:", AssertFailures.WARN_COLOR, false),
                    context.OrphanMonitor.OrphanCount,
                    beforeAttribute.Name + ":" + beforeAttribute.Line,
                    afterAttributes.Name + ":" + afterAttributes.Line);
            return String.Format("{0}\n Detected <{1}> orphan nodes during test setup stage!\n Check [b]{2}[/b] for unfreed instances!",
                AssertFailures.FormatValue("WARNING:", AssertFailures.WARN_COLOR, false),
                context.OrphanMonitor.OrphanCount,
                beforeAttribute != null
                    ? (beforeAttribute.Name + ":" + beforeAttribute.Line)
                    : (afterAttributes?.Name + ":" + afterAttributes?.Line));
        }
    }
}

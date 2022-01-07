using System;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace GdUnit3
{
    internal class AfterExecutionStage : ExecutionStage<AfterAttribute>
    {
        public AfterExecutionStage(Type type) : base("After", type)
        { }

        public override async Task Execute(ExecutionContext context)
        {
            context.MemoryPool.SetActive(StageName());
            context.OrphanMonitor.Start();
            await base.Execute(context);
            context.MemoryPool.ReleaseRegisteredObjects();
            context.OrphanMonitor.Stop();
            if (context.OrphanMonitor.OrphanCount > 0)
                context.ReportCollector.PushFront(new TestReport(TestReport.TYPE.WARN, 0, ReportOrphans(context)));
            context.FireAfterEvent();
        }

        private static AfterAttribute AfterAttribute(ExecutionContext context) => context.TestInstance
            .GetType()
            .GetMethods()
            .FirstOrDefault(m => m.IsDefined(typeof(AfterAttribute)))
            ?.GetCustomAttribute<AfterAttribute>();

        private static BeforeAttribute BeforeAttribute(ExecutionContext context) => context.TestInstance
            .GetType()
            .GetMethods()
            .FirstOrDefault(m => m.IsDefined(typeof(BeforeAttribute)))
            ?.GetCustomAttribute<BeforeAttribute>();

        private static string ReportOrphans(ExecutionContext context)
        {
            BeforeAttribute beforeAttribute = BeforeAttribute(context);
            AfterAttribute afterAttributes = AfterAttribute(context);

            if (beforeAttribute != null && afterAttributes != null)
                return String.Format("{0}\n Detected <{1}> orphan nodes during test suite setup stage!\n Check [b]{2}[/b] and [b]{3}[/b] for unfreed instances!",
                    AssertFailures.FormatValue("WARNING:", AssertFailures.WARN_COLOR, false),
                    context.OrphanMonitor.OrphanCount,
                    beforeAttribute.Name + ":" + beforeAttribute.Line,
                    afterAttributes.Name + ":" + afterAttributes.Line);
            return String.Format("{0}\n Detected <{1}> orphan nodes during test suite setup stage!\n Check [b]{2}[/b] for unfreed instances!",
                AssertFailures.FormatValue("WARNING:", AssertFailures.WARN_COLOR, false),
                context.OrphanMonitor.OrphanCount,
                beforeAttribute != null
                    ? (beforeAttribute.Name + ":" + beforeAttribute.Line)
                    : (afterAttributes.Name + ":" + afterAttributes.Line));
        }
    }
}



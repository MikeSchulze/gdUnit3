using System;
using System.Linq;

namespace GdUnit3
{
    public class AfterTestExecutionStage : ExecutionStage<AfterTestAttribute>
    {
        public AfterTestExecutionStage(Type type) : base("AfterTest", type)
        { }

        public override void Execute(ExecutionContext context)
        {
            if (!context.IsSkipped())
            {
                context.MemoryPool.SetActive(StageName());
                context.OrphanMonitor.Start();
                base.Execute(context);
                context.MemoryPool.ReleaseRegisteredObjects();
                context.OrphanMonitor.Stop();
            }
            context.FireAfterTestEvent();
        }
    }
}

using System;

namespace GdUnit3
{
    public class AfterExecutionStage : ExecutionStage<AfterAttribute>
    {
        public AfterExecutionStage(Type type) : base("After", type)
        { }

        public override void Execute(ExecutionContext context)
        {
            context.MemoryPool.SetActive(StageName());
            context.OrphanMonitor.Start();
            base.Execute(context);
            context.MemoryPool.ReleaseRegisteredObjects();
            context.OrphanMonitor.Stop();
            context.FireAfterEvent();
        }
    }
}

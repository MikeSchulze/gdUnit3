using System;

namespace GdUnit3
{
    public class BeforeExecutionStage : ExecutionStage<BeforeAttribute>
    {
        public BeforeExecutionStage(Type type) : base("Before", type)
        { }

        public override void Execute(ExecutionContext context)
        {
            context.FireBeforeEvent();
            context.OrphanMonitor.Start(true);
            base.Execute(context);
            context.OrphanMonitor.Stop();
        }
    }
}

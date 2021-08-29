using System;

namespace GdUnit3
{
    public class BeforeTestExecutionStage : ExecutionStage<BeforeTestAttribute>
    {
        public BeforeTestExecutionStage(Type type) : base("BeforeTest", type)
        { }

        public override void Execute(ExecutionContext context)
        {
            context.FireBeforeTestEvent();
            if (!context.IsSkipped())
            {
                context.OrphanMonitor.Start(true);
                base.Execute(context);
                context.OrphanMonitor.Stop();
            }
        }
    }
}

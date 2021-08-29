using System;
using System.Threading.Tasks;

namespace GdUnit3.Executions
{
    internal class BeforeTestExecutionStage : ExecutionStage<BeforeTestAttribute>
    {
        public BeforeTestExecutionStage(Type type) : base("BeforeTest", type)
        { }

        public override async Task Execute(ExecutionContext context)
        {
            context.FireBeforeTestEvent();
            if (!context.IsSkipped)
            {
                context.MemoryPool.SetActive(StageName());
                context.OrphanMonitor.Start(true);
                await base.Execute(context);
                context.OrphanMonitor.Stop();
            }
        }
    }
}

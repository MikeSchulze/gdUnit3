using System;
using System.Threading.Tasks;

namespace GdUnit3.Executions
{
    internal class BeforeExecutionStage : ExecutionStage<BeforeAttribute>
    {
        public BeforeExecutionStage(Type type) : base("Before", type)
        { }

        public override async Task Execute(ExecutionContext context)
        {
            context.FireBeforeEvent();
            context.MemoryPool.SetActive(StageName());
            context.OrphanMonitor.Start(true);
            await base.Execute(context);
            context.OrphanMonitor.Stop();
        }
    }
}

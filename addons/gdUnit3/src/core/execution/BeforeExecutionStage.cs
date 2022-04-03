using System;
using System.Threading.Tasks;

namespace GdUnit3.Executions
{
    internal class BeforeExecutionStage : ExecutionStage<BeforeAttribute>
    {
        public BeforeExecutionStage(TestSuite testSuite) : base("Before", testSuite.Instance.GetType())
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

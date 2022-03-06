using System;
using System.Threading.Tasks;

namespace GdUnit3.Executions
{
    internal class BeforeTestExecutionStage : ExecutionStage<BeforeTestAttribute>
    {
        public BeforeTestExecutionStage(TestSuite testSuite) : base("BeforeTest", testSuite.Instance.GetType())
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

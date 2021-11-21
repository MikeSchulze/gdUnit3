using System;

namespace GdUnit3
{
    public sealed class TestCaseExecutionStage : IExecutionStage
    {
        public TestCaseExecutionStage(Type type)
        {
            BeforeStage = new BeforeTestExecutionStage(type);
            AfterStage = new AfterTestExecutionStage(type);
        }

        public string StageName() => "TestCases";

        private IExecutionStage BeforeStage
        { get; set; }
        private IExecutionStage AfterStage
        { get; set; }


        public void Execute(ExecutionContext context)
        {
            BeforeStage.Execute(context);
            using (ExecutionContext currentContext = new ExecutionContext(context))
            {
                currentContext.MemoryPool.SetActive(StageName());
                currentContext.OrphanMonitor.Start(true);
                while (!currentContext.IsSkipped() && currentContext.CurrentIteration != 0)
                {
                    currentContext.Test.Execute(currentContext);
                }
                currentContext.MemoryPool.ReleaseRegisteredObjects();
                currentContext.OrphanMonitor.Stop();
            }
            AfterStage.Execute(context);
        }
    }
}

using System;

namespace GdUnit3
{
    public sealed class TestCaseExecutionStage : IExecutionStage
    {
        public TestCaseExecutionStage(Type type)
        {
            BeforeTestStage = new BeforeTestExecutionStage(type);
            AfterTestStage = new AfterTestExecutionStage(type);
        }

        public string StageName() => "TestCases";

        private IExecutionStage BeforeTestStage
        { get; set; }
        private IExecutionStage AfterTestStage
        { get; set; }


        public void Execute(ExecutionContext context)
        {
            BeforeTestStage.Execute(context);
            using (ExecutionContext currentContext = new ExecutionContext(context))
            {
                currentContext.OrphanMonitor.Start(true);
                while (!currentContext.IsSkipped() && currentContext.CurrentIteration != 0)
                {
                    currentContext.Test.Execute(currentContext);
                }
                currentContext.OrphanMonitor.Stop();
            }
            AfterTestStage.Execute(context);
        }
    }
}

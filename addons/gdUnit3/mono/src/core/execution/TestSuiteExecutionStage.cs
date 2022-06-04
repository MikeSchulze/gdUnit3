using System;
using System.Threading.Tasks;

namespace GdUnit3.Executions
{
    internal sealed class TestSuiteExecutionStage : IExecutionStage
    {
        public TestSuiteExecutionStage(TestSuite testSuite)
        {
            BeforeStage = new BeforeExecutionStage(testSuite);
            AfterStage = new AfterExecutionStage(testSuite);
            BeforeTestStage = new BeforeTestExecutionStage(testSuite);
            AfterTestStage = new AfterTestExecutionStage(testSuite);
            TestCaseStage = new TestCaseExecutionStage();
        }

        public string StageName() => "TestSuite";

        private IExecutionStage BeforeStage
        { get; set; }

        private IExecutionStage AfterStage
        { get; set; }

        private IExecutionStage BeforeTestStage
        { get; set; }

        private IExecutionStage AfterTestStage
        { get; set; }

        private IExecutionStage TestCaseStage
        { get; set; }

        public async Task Execute(ExecutionContext testSuiteContext)
        {
            await BeforeStage.Execute(testSuiteContext);

            foreach (TestCase testCase in testSuiteContext.TestSuite.TestCases)
            {
                using (ExecutionContext testCaseContext = new ExecutionContext(testSuiteContext, testCase))
                {
                    await BeforeTestStage.Execute(testCaseContext);
                    using (ExecutionContext context = new ExecutionContext(testCaseContext))
                    {
                        await TestCaseStage.Execute(context);
                    }
                    await AfterTestStage.Execute(testCaseContext);
                }
            }
            await AfterStage.Execute(testSuiteContext);
        }
    }
}

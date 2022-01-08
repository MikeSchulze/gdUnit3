using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GdUnit3
{
    internal sealed class TestSuiteExecutionStage : IExecutionStage
    {
        public TestSuiteExecutionStage(Type type)
        {
            BeforeStage = new BeforeExecutionStage(type);
            AfterStage = new AfterExecutionStage(type);
            BeforeTestStage = new BeforeTestExecutionStage(type);
            AfterTestStage = new AfterTestExecutionStage(type);
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

            foreach (TestCase testCase in TestCases(testSuiteContext))
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

        private bool IsIncluded(string testCaseName, ExecutionContext context)
        {
            foreach (Godot.Node element in context.TestInstance.GetChildren())
            {
                if (testCaseName == element.Name)
                {
                    return true;
                }
            }
            return false;
        }

        private IEnumerable<TestCase> TestCases(ExecutionContext context)
        {
            // filter by only included test cases
            return CsTools.GetTestCases(context.TestInstance.GetType()).Where(test => IsIncluded(test.Name, context));
        }
    }
}

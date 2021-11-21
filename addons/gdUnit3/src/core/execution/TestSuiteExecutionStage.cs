using System;
using System.Collections.Generic;
using System.Linq;

namespace GdUnit3
{
    public sealed class TestSuiteExecutionStage : IExecutionStage
    {
        public TestSuiteExecutionStage(Type type)
        {
            BeforeStage = new BeforeExecutionStage(type);
            AfterStage = new AfterExecutionStage(type);
            TestCaseStage = new TestCaseExecutionStage(type);
        }

        public string StageName() => "TestSuite";

        private IExecutionStage BeforeStage
        { get; set; }
        private IExecutionStage AfterStage
        { get; set; }

        private IExecutionStage TestCaseStage
        { get; set; }

        public void Execute(ExecutionContext context)
        {
            BeforeStage.Execute(context);

            foreach (TestCase testCase in TestCases(context))
            {
                using (ExecutionContext currentContext = new ExecutionContext(context, testCase))
                {
                    TestCaseStage.Execute(currentContext);
                }
            }
            AfterStage.Execute(context);
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

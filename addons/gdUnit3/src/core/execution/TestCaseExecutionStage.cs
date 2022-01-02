using System;
using System.Threading;
using System.Reflection;

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
            context.MemoryPool.SetActive(StageName());
            context.OrphanMonitor.Start(true);

            var testInstance = context.TestInstance;
            var testCase = context.Test;
            try
            {
                while (!context.IsSkipped() && context.CurrentIteration != 0)
                {
                    testCase.MethodInfo.Invoke(testInstance, testCase.Arguments);
                }
            }
            catch (TargetInvocationException e)
            {
                var baseException = e.GetBaseException();
                if (baseException is TestFailedException)
                {
                    if (context.FailureReporting)
                    {
                        var ex = baseException as TestFailedException;
                        context.ReportCollector.Consume(new TestReport(TestReport.TYPE.FAILURE, ex.LineNumber, ex.Message));
                    }
                }
                else
                {
                    // unexpected exceptions
                    Godot.GD.PushError(baseException.Message);
                    Godot.GD.PushError(baseException.StackTrace);
                    context.ReportCollector.Consume(new TestReport(TestReport.TYPE.ABORT, -1, baseException.Message));
                }
            }
            catch (Exception e)
            {
                // unexpected exceptions
                Godot.GD.PushError(e.Message);
                Godot.GD.PushError(e.StackTrace);
                context.ReportCollector.Consume(new TestReport(TestReport.TYPE.ABORT, -1, e.Message));
            }
            finally
            {
                context.MemoryPool.ReleaseRegisteredObjects();
                context.OrphanMonitor.Stop();
            }
            AfterStage.Execute(context);

        }
    }
}

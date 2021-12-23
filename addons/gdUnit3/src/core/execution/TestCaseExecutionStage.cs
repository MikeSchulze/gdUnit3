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
            using (ExecutionContext currentContext = new ExecutionContext(context))
            {
                currentContext.MemoryPool.SetActive(StageName());
                currentContext.OrphanMonitor.Start(true);

                var testInstance = currentContext.TestInstance;
                var testCase = currentContext.Test;
                try
                {
                    // save current test suite instance used by assertions to register report resolver
                    Thread.SetData(Thread.GetNamedDataSlot("TestInstance"), testInstance);
                    while (!currentContext.IsSkipped() && currentContext.CurrentIteration != 0)
                    {
                        testCase.MethodInfo.Invoke(testInstance, testCase.Arguments);
                    }
                }
                catch (TargetInvocationException e)
                {
                    var baseException = e.GetBaseException();
                    if (baseException is TestFailedException)
                    {
                        if (currentContext.FailureReporting)
                        {
                            var ex = baseException as TestFailedException;
                            currentContext.ReportCollector.Consume(new TestReport(TestReport.TYPE.FAILURE, ex.LineNumber, ex.Message));
                        }
                    }
                    else
                    {
                        // unexpected exceptions
                        Godot.GD.PushError(baseException.Message);
                        Godot.GD.PushError(baseException.StackTrace);
                        currentContext.ReportCollector.Consume(new TestReport(TestReport.TYPE.ABORT, -1, baseException.Message));
                    }
                }
                catch (Exception e)
                {
                    // unexpected exceptions
                    Godot.GD.PushError(e.Message);
                    Godot.GD.PushError(e.StackTrace);
                    currentContext.ReportCollector.Consume(new TestReport(TestReport.TYPE.ABORT, -1, e.Message));
                }
                finally
                {
                    currentContext.MemoryPool.ReleaseRegisteredObjects();
                    currentContext.OrphanMonitor.Stop();
                }
            }
            AfterStage.Execute(context);
        }
    }
}

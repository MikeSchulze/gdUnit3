using System;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.CompilerServices;

namespace GdUnit3.Executions
{
    using Exceptions;

    internal abstract class ExecutionStage<T> : IExecutionStage
    {
        private readonly string _name;

        protected ExecutionStage(string name, Type? type = null)
        {
            _name = name;
            var method = type?
               .GetMethods()
               .FirstOrDefault(m => m.IsDefined(typeof(T)));
            InitExecutionAttributes(method);
        }

        protected void InitExecutionAttributes(MethodInfo? method)
        {
            Method = method;
            IsAsync = method?.GetCustomAttribute(typeof(AsyncStateMachineAttribute)) != null;
            IsTask = method?.ReturnType.IsEquivalentTo(typeof(Task)) ?? false;
        }

        public virtual async Task Execute(ExecutionContext context)
        {
            // no stage defined?
            if (Method == null)
            {
                await Task.Run(() => { });
                return;
            }

            try
            {
                // if the method is defined asynchronously, the return type must be a Task
                if (IsAsync != IsTask)
                {
                    context.ReportCollector.Consume(new TestReport(TestReport.TYPE.FAILURE, StageAttributes.Line, $"Invalid method signature found at: {StageAttributes.Name}.\n You must return a <Task> for an asynchronously specified method."));
                    return;
                }
                await ExecuteStage(context.TestSuite, Method, MethodArguments);
            }
            catch (ExecutionTimeoutException e)
            {
                if (context.FailureReporting)
                    context.ReportCollector.Consume(new TestReport(TestReport.TYPE.INTERUPTED, e.LineNumber, e.Message));
            }
            catch (TestFailedException e)
            {
                if (context.FailureReporting)
                    context.ReportCollector.Consume(new TestReport(TestReport.TYPE.FAILURE, e.LineNumber, e.Message));
            }
            catch (TargetInvocationException e)
            {
                var baseException = e.GetBaseException();
                if (baseException is TestFailedException)
                {
                    var ex = baseException as TestFailedException;
                    if (ex != null && context.FailureReporting)
                        context.ReportCollector.Consume(new TestReport(TestReport.TYPE.FAILURE, ex.LineNumber, ex.Message));
                }
                else
                {
                    // unexpected exceptions
                    Godot.GD.PushError(baseException.Message);
                    Godot.GD.PushError(baseException.StackTrace);

                    StackTrace stack = new StackTrace(baseException, true);
                    var lineNumber = stack.FrameCount > 1 ? stack.GetFrame(1).GetFileLineNumber() : -1;
                    context.ReportCollector.Consume(new TestReport(TestReport.TYPE.ABORT, lineNumber, baseException.Message));
                }
            }
            catch (Exception e)
            {
                // unexpected exceptions
                Godot.GD.PushError(e.Message);
                Godot.GD.PushError(e.StackTrace);
                StackTrace stack = new StackTrace(e, true);
                var lineNumber = stack.FrameCount > 1 ? stack.GetFrame(1).GetFileLineNumber() : -1;
                context.ReportCollector.Consume(new TestReport(TestReport.TYPE.ABORT, lineNumber, e.Message));
            }
        }

        private async Task ExecuteStage(TestSuite testSuite, MethodInfo method, object[] args)
        {
            var timeout = TimeSpan.FromMilliseconds(StageAttributes.Timeout != -1 ? StageAttributes.Timeout : DefaultTimeout);
            using (var tokenSource = new CancellationTokenSource())
            {
                object? obj = method.Invoke(testSuite.Instance, args);
                Task task = obj is Task ? (Task)obj : Task.Run(() => { });
                var completedTask = await Task.WhenAny(task, Task.Delay(timeout, tokenSource.Token));
                tokenSource.Cancel();
                if (completedTask == task)
                    // Very important in order to propagate exceptions
                    await task;
                else
                    throw new ExecutionTimeoutException($"The execution has timed out after {timeout.TotalMilliseconds}ms.", StageAttributes?.Line ?? 0);
            }
        }

        public string StageName() => _name;

        private bool IsAsync { get; set; }

        private bool IsTask { get; set; }

        private int DefaultTimeout { get; set; } = 30000;

#nullable enable
        private MethodInfo? Method { get; set; }
#nullable disable
        protected object[] MethodArguments { get; set; } = new object[] { };

        private TestStageAttribute StageAttributes => Method?.GetCustomAttribute<TestStageAttribute>();
    }
}

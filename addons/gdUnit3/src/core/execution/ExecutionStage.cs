
using System;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.CompilerServices;

namespace GdUnit3
{
    internal abstract class ExecutionStage<T> : IExecutionStage
    {
        private readonly string _name;
#nullable enable
        protected readonly MethodInfo? _mi;
#nullable disable
        protected ExecutionStage(string name, Type type)
        {
            _name = name;
            _mi = type
               .GetMethods()
               .FirstOrDefault(m => m.IsDefined(typeof(T)));
            // evaluate method signature
            IsAsync = (AsyncStateMachineAttribute)_mi?.GetCustomAttribute(typeof(AsyncStateMachineAttribute)) != null;
            IsTask = _mi?.ReturnType.IsEquivalentTo(typeof(Task)) ?? false;
            // set default timeout to 30s
            DefaultTimeout = 30000;
        }

        public virtual async Task Execute(ExecutionContext context)
        {
            try
            {
                // if the method is defined asynchronously, the return type must be a Task
                if (IsAsync && !IsTask)
                {
                    context.ReportCollector.Consume(new TestReport(TestReport.TYPE.FAILURE, 0, "Invalid method found, you have to return a Task for an async Method."));
                    return;
                }
                await RunTask(Invoke(context), TimeSpan.FromMilliseconds(context.CurrentTestCase?.Attributes.Timeout ?? DefaultTimeout));
            }
            catch (ExecutionTimeoutException e)
            {
                Godot.GD.PrintS(e.Message, e.LineNumber);
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
        }

        private async Task RunTask(object obj, TimeSpan timeout)
        {
            using (var tokenSource = new CancellationTokenSource())
            {
                Task task = obj is Task ? obj as Task : Task.Run(() => { });
                var completedTask = await Task.WhenAny(task, Task.Delay(timeout, tokenSource.Token));
                if (completedTask == task)
                {
                    tokenSource.Cancel();
                    await task;  // Very important in order to propagate exceptions
                }
                else
                    throw new ExecutionTimeoutException($"The execution has timed out after {timeout.TotalMilliseconds}ms.");
            }
        }

        protected virtual object Invoke(ExecutionContext context) => _mi?.Invoke(context.TestInstance, new object[] { });

        public string StageName() => _name;

        protected bool IsAsync { get; private set; }

        protected bool IsTask { get; private set; }

        public int DefaultTimeout { get; set; }
    }
}

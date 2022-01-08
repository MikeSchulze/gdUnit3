using System;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.CompilerServices;

namespace GdUnit3.Executions
{
    internal abstract class ExecutionStage<T> : IExecutionStage
    {
        private readonly string _name;

        protected ExecutionStage(string name, Type type = null)
        {
            _name = name;
            var method = type?
               .GetMethods()
               .FirstOrDefault(m => m.IsDefined(typeof(T)));
            InitExecutionAttributes(method, new object[] { });
        }

        protected void InitExecutionAttributes(MethodInfo method, object[] args)
        {
            Method = method;
            MethodArguments = args;
            IsAsync = (AsyncStateMachineAttribute)method?.GetCustomAttribute(typeof(AsyncStateMachineAttribute)) != null;
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
                await ExecuteStage(context.TestInstance, Method, MethodArguments);
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

        private async Task ExecuteStage(object instance, MethodInfo method, object[] args)
        {
            var timeout = TimeSpan.FromMilliseconds(StageAttributes.Timeout != -1 ? StageAttributes.Timeout : DefaultTimeout);
            using (var tokenSource = new CancellationTokenSource())
            {
                var obj = method.Invoke(instance, args);
                Task task = obj is Task ? obj as Task : Task.Run(() => { });
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

        private MethodInfo? Method { get; set; }

        private object[] MethodArguments { get; set; } = new object[] { };

        private TestStageAttribute StageAttributes => Method?.GetCustomAttribute<TestStageAttribute>();
    }
}

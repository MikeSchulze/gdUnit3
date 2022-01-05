
using System;
using System.Linq;
using System.Reflection;

namespace GdUnit3
{
    public abstract class ExecutionStage<T> : IExecutionStage
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
        }

        public virtual void Execute(ExecutionContext context)
        {
            try
            {
                Invoke(context);
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

        protected virtual void Invoke(ExecutionContext context) => _mi?.Invoke(context.TestInstance, new object[] { });

        public string StageName() => _name;
    }
}

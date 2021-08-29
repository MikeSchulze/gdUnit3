
using System;
using System.Linq;
using System.Reflection;

namespace GdUnit3
{
    public abstract class ExecutionStage<T> : IExecutionStage
    {
        private readonly string _name;
#nullable enable
        private readonly MethodInfo? _mi;
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
            _mi?.Invoke(context.TestInstance, new object[] { });
        }

        public string StageName() => _name;
    }
}

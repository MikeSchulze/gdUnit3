using Godot.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;
using System;

namespace GdUnit3
{
    public sealed class TestCase : Godot.Reference, IExecutionStage
    {
        public TestCase(MethodInfo methodInfo)
        {
            this.Name = methodInfo.Name;
            this.MethodInfo = methodInfo;
            this.Parameters = CsTools.GetTestMethodParameters(methodInfo).ToArray();
        }

        public string Name
        { get; set; }

        public string StageName() => "TestCase";

        public TestCaseAttribute Attributes
        { get => MethodInfo.GetCustomAttribute<TestCaseAttribute>(); }

        public bool Skipped => Attribute.IsDefined(MethodInfo, typeof(IgnoreUntilAttribute));

        public Godot.Collections.Dictionary attributes()
        {
            var attributes = Attributes;
            return new Dictionary {
                    { "name", Name },
                    { "line_number", attributes.line },
                    { "timeout", attributes.timeout },
                    { "iterations", attributes.iterations },
                    { "seed", attributes.seed },
                };
        }
        private IEnumerable<object> Parameters
        { get; set; }

        private MethodInfo MethodInfo
        { get; set; }

        private IEnumerable<object> ResolveParam(object input)
        {
            if (input is IValueProvider)
            {
                return (input as IValueProvider).GetValues();
            }
            return new object[] { input };
        }

        public void Execute(ExecutionContext context)
        {
            object[] arguments = Parameters.SelectMany(ResolveParam).ToArray<object>();
            try
            {
                MethodInfo.Invoke(context.TestInstance, arguments);
            }
            catch (TargetInvocationException e)
            {
                var baseException = e.GetBaseException();
                if (baseException is TestFailedException)
                {
                    var ex = baseException as TestFailedException;
                    Godot.GD.PrintS("TestCase Failed:", String.Format("|{0}#{1}:{2}|", context.TestInstance.Name, Name, ex.LineNumber), ex.Message);
                    return;
                }
                // unexpected exceptions
                Godot.GD.PushError(baseException.Message);
                Godot.GD.PushError(baseException.StackTrace);
            }
            catch (Exception e)
            {
                // unexpected exceptions
                Godot.GD.PushError(e.Message);
                Godot.GD.PushError(e.StackTrace);
            }
        }
    }
}

using Godot.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;
using System;

namespace GdUnit3
{
    public sealed class TestCase : Godot.Reference
    {
        public TestCase(MethodInfo methodInfo)
        {
            this.Name = methodInfo.Name;
            this.MethodInfo = methodInfo;
            this.Parameters = CsTools.GetTestMethodParameters(methodInfo).ToArray();
        }

        public string Name
        { get; set; }

        public TestCaseAttribute Attributes
        { get => MethodInfo.GetCustomAttribute<TestCaseAttribute>(); }

        public bool Skipped => Attribute.IsDefined(MethodInfo, typeof(IgnoreUntilAttribute));

        public Godot.Collections.Dictionary attributes()
        {
            var attributes = Attributes;
            return new Dictionary {
                    { "name", Name },
                    { "line_number", attributes.Line },
                    { "timeout", attributes.Timeout },
                    { "iterations", attributes.Iterations },
                    { "seed", attributes.Seed },
                };
        }
        private IEnumerable<object> Parameters
        { get; set; }

        public MethodInfo MethodInfo
        { get; set; }

        private IEnumerable<object> ResolveParam(object input)
        {
            if (input is IValueProvider)
            {
                return (input as IValueProvider).GetValues();
            }
            return new object[] { input };
        }

        public object[] Arguments => Parameters.SelectMany(ResolveParam).ToArray<object>();

    }
}

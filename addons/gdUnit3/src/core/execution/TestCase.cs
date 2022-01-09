using System.Collections.Generic;
using System.Reflection;
using System.Linq;
using System;

using GdUnit3.Tools;

namespace GdUnit3.Executions
{
    public sealed class TestCase : Godot.Reference
    {
        public TestCase(MethodInfo methodInfo)
        {
            MethodInfo = methodInfo;
            Parameters = CsTools.GetTestMethodParameters(methodInfo).ToArray();
        }

        public string Name => MethodInfo.Name;

        public int Line => Attributes.Line;

        public TestCaseAttribute Attributes => MethodInfo.GetCustomAttribute<TestCaseAttribute>();

        public bool IsSkipped => Attribute.IsDefined(MethodInfo, typeof(IgnoreUntilAttribute));

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

using System.Collections.Generic;
using System.Reflection;
using System.Linq;
using System;

namespace GdUnit3.Executions
{
    internal sealed class TestCase
    {
        public TestCase(MethodInfo methodInfo)
        {
            MethodInfo = methodInfo;
            Parameters = InitialParameters();
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
                return ((IValueProvider)input).GetValues();
            }
            return new object[] { input };
        }

        private IEnumerable<object> InitialParameters()
        {
            return MethodInfo.GetParameters()
                .SelectMany(pi => pi.GetCustomAttributesData()
                    .Where(attr => attr.AttributeType == typeof(FuzzerAttribute))
                    .Select(attr =>
                    {
                        var arguments = attr.ConstructorArguments.Select(arg => arg.Value).ToArray();
                        return attr.Constructor.Invoke(arguments);
                    }
                )
             ).ToArray();
        }

        public object[] Arguments => Parameters.SelectMany(ResolveParam).ToArray<object>();

    }
}

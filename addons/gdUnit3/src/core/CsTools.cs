using System;
using System.Diagnostics.Contracts;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

using GdUnit3.Executions;

namespace GdUnit3.Tools
{
    public class CsTools : Godot.Reference
    {
        public static IEnumerable<TestCase> GetTestCases(String className)
        {
            System.Type type = System.Type.GetType(className);
            Contract.Requires(Attribute.IsDefined(type, typeof(TestSuiteAttribute)), "The class must have TestSuiteAttribute.");
            return type.GetMethods()
                .Where(m => m.IsDefined(typeof(TestCaseAttribute)))
                .Select(mi => new TestCase(mi))
                .ToArray();
        }

        // used from GdScript side, will be remove later
        public static bool IsTestSuite(String className)
        {
            System.Type type = System.Type.GetType(className);
            if (type == null)
            {
                return false;
            }
            return Attribute.IsDefined(type, typeof(TestSuiteAttribute));
        }

        public static IEnumerable<object> GetTestMethodParameters(MethodInfo methodInfo)
        {
            return methodInfo.GetParameters()
                .SelectMany(pi => pi.GetCustomAttributesData()
                    .Where(attr => attr.AttributeType == typeof(FuzzerAttribute))
                    .Select(attr =>
                    {
                        var arguments = attr.ConstructorArguments.Select(arg => arg.Value).ToArray();
                        return attr.Constructor.Invoke(arguments);
                    }
                )
             );
        }
    }
}

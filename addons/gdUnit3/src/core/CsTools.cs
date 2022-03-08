using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;

namespace GdUnit3.Tools
{
    public class CsTools : Godot.Reference
    {
        readonly static Regex RegexNamespace = new Regex("(?<=^namespace\\s)((?:\\w+)(?:[.](?:\\w+))*)", RegexOptions.Multiline);

        internal static string ParseNameSpace(String classPath)
        {
            if (!new FileInfo(classPath).Exists)
                return null;
            using (StreamReader sr = File.OpenText(classPath))
            {
                var all = sr.ReadToEnd();
                var match = RegexNamespace.Match(all);
                if (match.Success)
                {
                    return match.Value;
                }
            }
            return null;
        }

        internal static Type ParseType(String classPath)
        {
            try
            {
                var fi = new FileInfo(classPath);
                if (!fi.Exists)
                {
                    return null;
                }
                return Type.GetType(ParseNameSpace(classPath) + "." + fi.Name.Replace(".cs", ""));
            }
#pragma warning disable CS0168
            catch (Exception e)
            {
#pragma warning restore CS0168
                // ignore exception
                return null;
            }
        }

        public static bool IsTestSuite(String classPath)
        {
            var type = ParseType(classPath);
            return type != null ? Attribute.IsDefined(type, typeof(TestSuiteAttribute)) : false;
        }

        public static Godot.Node ParseTestSuite(String classPath)
        {
            try
            {
                var type = ParseType(classPath);
                var testSuite = new Godot.Node();
                testSuite.SetMeta("CS_TESTSUITE", true);
                testSuite.SetMeta("ResourcePath", classPath);
                testSuite.Name = type.Name;
                LoadTestCases(type)
                    .ToList()
                    .ForEach(testCase =>
                    {
                        var child = new Godot.Node();
                        child.Name = testCase.Name;
                        child.SetMeta("LineNumber", testCase.Line);
                        child.SetMeta("ResourcePath", classPath);
                        testSuite.AddChild(child);
                    });
                return testSuite;
            }
#pragma warning disable CS0168
            catch (Exception e)
            {
#pragma warning restore CS0168
                // ignore exception
                return null;
            }
        }

        private static IEnumerable<Executions.TestCase> LoadTestCases(Type type) => type.GetMethods()
            .Where(m => m.IsDefined(typeof(TestCaseAttribute)))
            .Select(mi => new Executions.TestCase(mi));

    }
}

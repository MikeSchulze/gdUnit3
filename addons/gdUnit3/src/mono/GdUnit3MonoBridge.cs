using Godot;
using System;
using GdUnit3.Core;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;


namespace GdUnit3
{
    public class GdUnit3MonoBridge : Reference
    {
        public static Godot.Collections.Dictionary CreateTestSuite(string sourcePath, int lineNumber, string testSuitePath)
        {
            var result = GdUnitTestSuiteBuilder.Build(NormalisizePath(sourcePath), lineNumber, NormalisizePath(testSuitePath));
            // we need to return the original resource name of the test suite on Godot site e.g. `res://foo/..` or `user://foo/..`
            if (result.ContainsKey("path"))
                result["path"] = testSuitePath;
            return new Godot.Collections.Dictionary(result);
        }

        public static bool IsTestSuite(string classPath)
        {
            var type = GdUnitTestSuiteBuilder.ParseType(NormalisizePath(classPath));
            return type != null ? Attribute.IsDefined(type, typeof(TestSuiteAttribute)) : false;
        }

        public static Godot.Node? ParseTestSuite(string classPath)
        {
            try
            {
                classPath = NormalisizePath(classPath);
                Type? type = GdUnitTestSuiteBuilder.ParseType(classPath);
                if (type == null)
                    return null;
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

        public static GdUnit3.IExecutor Executor(Godot.Node listener) =>
            new GdUnit3.Executions.Executor().AddGdTestEventListener(listener);

        private static string NormalisizePath(string path) =>
             (path.StartsWith("res://") || path.StartsWith("user://")) ? Godot.ProjectSettings.GlobalizePath(path) : path;

        private static IEnumerable<GdUnit3.Executions.TestCase> LoadTestCases(Type type) => type.GetMethods()
            .Where(m => m.IsDefined(typeof(TestCaseAttribute)))
            .Select(mi => new GdUnit3.Executions.TestCase(mi));
    }
}

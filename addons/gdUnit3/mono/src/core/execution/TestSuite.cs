using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using GdUnit3.Core;

namespace GdUnit3.Executions
{
    internal sealed class TestSuite : IDisposable
    {
        private Lazy<IEnumerable<Executions.TestCase>> _testCases = new Lazy<IEnumerable<Executions.TestCase>>();

        public int TestCaseCount => TestCases.Count<Executions.TestCase>();

        public IEnumerable<Executions.TestCase> TestCases => _testCases.Value;

        public string ResourcePath { get; set; }

        public string Name { get; set; }
        public string FullName => GetType().FullName;

        public object Instance { get; set; }

        public bool FilterDisabled { get; set; } = false;

        public TestSuite(string classPath, List<string> includedTests)
        {
            Type? type = GdUnitTestSuiteBuilder.ParseType(classPath);
            if (type == null)
            {
                throw new ArgumentException($"Can't parse testsuite {classPath}");
            }
            Instance = Activator.CreateInstance(type);
            Name = type.Name;
            ResourcePath = classPath;
            // we do lazy loding to only load test case one times
            _testCases = new Lazy<IEnumerable<Executions.TestCase>>(() => LoadTestCases(type, includedTests));
        }

        public TestSuite(Type type)
        {
            Instance = Activator.CreateInstance(type);
            Name = type.Name;
            ResourcePath = type.FullName;
            // we do lazy loding to only load test case one times
            _testCases = new Lazy<IEnumerable<Executions.TestCase>>(() => LoadTestCases(type, null));
        }

        private IEnumerable<Executions.TestCase> LoadTestCases(Type type, List<string>? includedTests)
        {
            return type.GetMethods()
                .Where(m => m.IsDefined(typeof(TestCaseAttribute)))
                .Where(m => includedTests == null || includedTests.Contains(m.Name))
                .Select(mi => new Executions.TestCase(mi));
        }

        public void Dispose()
        {
            if (Instance is IDisposable)
                ((IDisposable)Instance).Dispose();
        }
    }
}

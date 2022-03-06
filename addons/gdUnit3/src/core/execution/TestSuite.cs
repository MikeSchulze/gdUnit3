using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using GdUnit3.Tools;

namespace GdUnit3.Executions
{
    internal sealed class TestSuite : IDisposable
    {
        private Lazy<IEnumerable<Executions.TestCase>> _testCases = null;

        public int TestCaseCount => TestCases.Count<Executions.TestCase>();

        public IEnumerable<Executions.TestCase> TestCases => _testCases.Value;

        public string ResourcePath { get; set; }

        public string Name { get; set; }
        public string FullName => GetType().FullName;

        public object Instance { get; set; }

        public bool FilterDisabled { get; set; } = false;

        public TestSuite(string classPath)
        {
            Type type = CsTools.loadClass(classPath);
            Instance = Activator.CreateInstance(type);
            Name = type.Name;
            ResourcePath = classPath;
            // we do lazy loding to only load test case one times
            _testCases = new Lazy<IEnumerable<Executions.TestCase>>(() => LoadTestCases(type));
        }

        public TestSuite(Type type)
        {
            Instance = Activator.CreateInstance(type);
            Name = type.Name;
            ResourcePath = type.FullName;
            // we do lazy loding to only load test case one times
            _testCases = new Lazy<IEnumerable<Executions.TestCase>>(() => LoadTestCases(type));
        }

        private IEnumerable<Executions.TestCase> LoadTestCases(Type type)
        {
            return type.GetMethods()
                .Where(m => m.IsDefined(typeof(TestCaseAttribute)))
                //.Where(m => FilterDisabled || FindNode(m.Name, false, false) != null)
                .Select(mi => new Executions.TestCase(mi));
        }

        public void Dispose()
        {
            Instance = null;
        }
    }
}

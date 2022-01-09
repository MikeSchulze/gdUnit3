using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.Linq;
using System.Reflection;


namespace GdUnit3
{
    /** <summary>
    This class is the main class to implement your unit tests<br />
    You have to extend and implement your test cases as described<br />
    e.g<br />
    <br />
      For detailed instructions see <a href="https://github.com/MikeSchulze/gdUnit3/wiki/TestSuite">HERE</a> <br />
      
    <example>For example:
    
    <code>
    [TestSuite]
    public class MyExampleTest : GdUnit3.TestSuite
    {
        [TestCase]
        public void testCaseA()
        {
             AssertThat("value").IsEqual("value");
        }
    }
    </code>
    </example>
    </summary> */
    public abstract class TestSuite : Node
    {
        private Lazy<IEnumerable<Executions.TestCase>> _testCases = null;

        public int TestCaseCount => TestCases.Count<Executions.TestCase>();

        public IEnumerable<Executions.TestCase> TestCases => _testCases.Value;

        public string ResourcePath => (GetScript() as Script).ResourcePath;

        public new string Name => base.Name;

        public string FullName => GetType().FullName;

        public bool FilterDisabled { get; set; } = false;

        public TestSuite()
        {
            Type type = GetType();
            base.Name = type.Name;
            // we do lazy loding to only load test case one times
            _testCases = new Lazy<IEnumerable<Executions.TestCase>>(() => LoadTestCases(type));
        }

        private IEnumerable<Executions.TestCase> LoadTestCases(Type type)
        {
            return type.GetMethods()
                .Where(m => m.IsDefined(typeof(TestCaseAttribute)))
                .Where(m => FilterDisabled || FindNode(m.Name, false, false) != null)
                .Select(mi => new Executions.TestCase(mi));
        }
    }
}

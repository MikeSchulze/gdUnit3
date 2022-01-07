using System;

namespace GdUnit3
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class TestCaseAttribute : TestStageAttribute
    {
        /// <summary>
        /// Sets the timeout in ms to interrupt the test if the test execution takes longer as the given value.
        /// </summary>
        public int Timeout { get; set; }

        /// <summary>
        /// Sets the starting point of random values by given seed.
        /// </summary>
        public double Seed { get; set; }

        /// <summary>
        /// Sets the number of test iterations for a parameterized test
        /// </summary>
        public int Iterations { get; set; }

        public TestCaseAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Name = name;
            Line = line;
            Timeout = -1;
            Seed = 1;
            Iterations = 1;
        }
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class BeforeTestAttribute : TestStageAttribute
    {
        public BeforeTestAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
        }
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class AfterTestAttribute : TestStageAttribute
    {
        public AfterTestAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
        }
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class IgnoreUntilAttribute : TestStageAttribute
    {
        public IgnoreUntilAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
        }
    }
}

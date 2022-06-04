using System;

namespace GdUnit3
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class TestCaseAttribute : TestStageAttribute
    {
        /// <summary>
        /// Sets the starting point of random values by given seed.
        /// </summary>
        public double Seed { get; set; } = 1;

        /// <summary>
        /// Sets the number of test iterations for a parameterized test
        /// </summary>
        public int Iterations { get; set; } = 1;

        public TestCaseAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Name = name;
            Line = line;
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

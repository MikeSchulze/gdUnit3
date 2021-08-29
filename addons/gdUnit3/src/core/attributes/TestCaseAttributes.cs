using System;

namespace GdUnit3
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class TestCaseAttribute : Attribute
    {
        public int timeout = -1;

        public double seed = 1.0;

        public int iterations = 1;

        public readonly int line;

        public TestCaseAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0)
        {
            this.line = line;
        }
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class BeforeTestAttribute : Attribute
    {
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class AfterTestAttribute : Attribute
    {
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class IgnoreUntilAttribute : Attribute
    {

        public string Description
        { get; set; }

        public IgnoreUntilAttribute() { }
        public IgnoreUntilAttribute(string description)
        {
            Description = description;
        }
    }
}

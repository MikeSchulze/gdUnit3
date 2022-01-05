using System;

namespace GdUnit3
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class TestCaseAttribute : Attribute
    {
        public int Timeout { get; set; }

        public double Seed { get; set; }

        public int Iterations { get; set; }

        public int Line { get; private set; }

        public string Name { get; private set; }

        public TestCaseAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
            Timeout = -1;
            Seed = 1;
            Iterations = 1;
        }
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class BeforeTestAttribute : Attribute
    {
        public int Line { get; private set; }

        public string Name { get; private set; }

        public BeforeTestAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
        }
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class AfterTestAttribute : Attribute
    {
        public int Line { get; private set; }

        public string Name { get; private set; }

        public AfterTestAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
        }
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

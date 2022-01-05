using System;

namespace GdUnit3
{
    [AttributeUsage(AttributeTargets.Class)]
    public class TestSuiteAttribute : Attribute
    {
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class BeforeAttribute : Attribute
    {
        public int Line { get; private set; }

        public string Name { get; private set; }

        public BeforeAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
        }
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class AfterAttribute : Attribute
    {
        public int Line { get; private set; }

        public string Name { get; private set; }

        public AfterAttribute([System.Runtime.CompilerServices.CallerLineNumber] int line = 0, [System.Runtime.CompilerServices.CallerMemberName] string name = "")
        {
            Line = line;
            Name = name;
        }
    }
}

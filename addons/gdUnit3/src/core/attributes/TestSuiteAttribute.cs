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
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class AfterAttribute : Attribute
    {
    }
}

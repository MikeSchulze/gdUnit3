
using System;
using System.Collections.Generic;

namespace GdUnit3
{
    [AttributeUsage(AttributeTargets.Parameter, AllowMultiple = false, Inherited = false)]
    public class FuzzerAttribute : System.Attribute, IValueProvider
    {

        public int _value;
        public FuzzerAttribute(int value)
        {
            _value = value;
        }

        public IEnumerable<object> GetValues()
        {
            _value += 1;
            yield return _value;
        }
    }
}

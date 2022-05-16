/// A tuple implementation to hold two or many values 
using System.Collections.Generic;

namespace GdUnit3.Asserts
{
    public interface ITuple
    {
        public IEnumerable<object?> Values
        { get; set; }
    }
}

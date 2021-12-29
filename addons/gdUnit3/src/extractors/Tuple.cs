/// A tuple implementation to hold two or many values
using System.Collections.Generic;
using System.Linq;

namespace GdUnit3
{
    sealed class Tuple : ITuple
    {
        public Tuple(params object[] args)
        {
            Values = args?.ToList<object>() ?? Enumerable.Empty<object>();
        }

        public IEnumerable<object> Values
        { get; set; }


        public override string ToString()
        {
            return string.Format("tuple({0})", string.Join(", ", Values.Select(v => v == null ? "Null" : v)));
        }
    }
}

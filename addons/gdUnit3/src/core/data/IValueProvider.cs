
using System.Collections.Generic;

namespace GdUnit3
{
    public interface IValueProvider
    {
        public IEnumerable<object> GetValues();
    }
}

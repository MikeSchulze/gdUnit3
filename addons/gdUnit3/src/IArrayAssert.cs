using System.Collections;

namespace GdUnit3
{
    /// <summary> An Assertion Tool to verify arrays </summary>
    public interface IArrayAssert : IAssertBase<IEnumerable>
    {


        /// <summary> Verifies that the current String is equal to the given one, ignoring case considerations.</summary>
        public IArrayAssert IsEqualIgnoringCase(IEnumerable expected);

        /// <summary> Verifies that the current String is not equal to the given one, ignoring case considerations.</summary>
        public IArrayAssert IsNotEqualIgnoringCase(IEnumerable expected);

        /// <summary> Verifies that the current Array is empty, it has a size of 0.</summary>
        public IArrayAssert IsEmpty();

        /// <summary> Verifies that the current Array is not empty, it has a size of minimum 1.</summary>
        public IArrayAssert IsNotEmpty();

        /// <summary> Verifies that the current Array has a size of given value.</summary>
        public IArrayAssert HasSize(int expected);

        /// <summary> Verifies that the current Array contains the given values, in any order.</summary>
        public IArrayAssert Contains(IEnumerable expected);

    }
}

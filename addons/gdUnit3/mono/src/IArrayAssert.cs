using System.Collections;

namespace GdUnit3.Asserts
{
    /// <summary> An Assertion tool to verify arrays </summary>
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

        /// <summary> Verifies that the current Array contains the given values, in any order.</summary>
        public IArrayAssert Contains(params object?[] expected);

        /// <summary> Verifies that the current Array contains exactly only the given values and nothing else, in same order.</summary>
        public IArrayAssert ContainsExactly(params object?[] expected);

        /// <summary> Verifies that the current Array contains exactly only the given values and nothing else, in same order.</summary>
        public IArrayAssert ContainsExactly(IEnumerable expected);

        /// <summary> Verifies that the current Array contains exactly only the given values and nothing else, in any order.</summary>
        public IArrayAssert ContainsExactlyInAnyOrder(params object?[] expected);

        /// <summary> Verifies that the current Array contains exactly only the given values and nothing else, in any order.</summary>
        public IArrayAssert ContainsExactlyInAnyOrder(IEnumerable expected);

        /// <summary>
        /// Extracts all values by given function name and optional arguments into a new ArrayAssert<br />
        /// If the elements not accessible by `func_name` the value is converted to `"n.a"`, expecting null values
        /// </summary>
        public IArrayAssert Extract(string funcName, params object[] args);

        /// <summary>
        /// Extracts all values by given extractor's into a new ArrayAssert<br />
        /// If the elements not extractable than the value is converted to `"n.a"`, expecting null values
        /// </summary>
        public IArrayAssert ExtractV(params IValueExtractor[] extractors);

        public new IArrayAssert OverrideFailureMessage(string message);
    }
}

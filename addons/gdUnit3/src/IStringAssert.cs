namespace GdUnit3.Asserts
{
    /// <summary> An Assertion Tool to verify string values </summary>
    public interface IStringAssert : IAssertBase<string>
    {
        enum Compare
        {
            EQUAL,
            LESS_THAN,
            LESS_EQUAL,
            GREATER_THAN,
            GREATER_EQUAL,
        }

        /// <summary> Verifies that the current String is equal to the given one, ignoring case considerations.</summary>
        public IStringAssert IsEqualIgnoringCase(string expected);

        /// <summary> Verifies that the current String is not equal to the given one, ignoring case considerations.</summary>
        public IStringAssert IsNotEqualIgnoringCase(string expected);

        /// <summary> Verifies that the current String is empty, it has a length of 0.</summary>
        public IStringAssert IsEmpty();

        /// <summary> Verifies that the current String is not empty, it has a length of minimum 1.</summary>
        public IStringAssert IsNotEmpty();

        /// <summary> Verifies that the current String contains the given String.</summary>
        public IStringAssert Contains(string expected);

        /// <summary> Verifies that the current String does not contain the given String.</summary>
        public IStringAssert NotContains(string expected);

        /// <summary> Verifies that the current String does not contain the given String, ignoring case considerations.</summary>
        public IStringAssert ContainsIgnoringCase(string expected);

        /// <summary> Verifies that the current String does not contain the given String, ignoring case considerations.</summary>
        public IStringAssert NotContainsIgnoringCase(string expected);

        /// <summary> Verifies that the current String starts with the given prefix.</summary>
        public IStringAssert StartsWith(string expected);

        /// <summary> Verifies that the current String ends with the given suffix.</summary>
        public IStringAssert EndsWith(string expected);

        /// <summary> Verifies that the current String has the expected length by used comparator.</summary>
        public IStringAssert HasLength(int lenght, Compare comparator = Compare.EQUAL);

        public new IStringAssert OverrideFailureMessage(string message);
    }
}

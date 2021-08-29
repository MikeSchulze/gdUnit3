namespace GdUnit3.Asserts
{
    /// <summary> Base interface for number assertions.</summary>
    public interface INumberAssert<V> : IAssertBase<V>
    {
        /// <summary> Verifies that the current value is less than the given one.</summary>
        public INumberAssert<V> IsLess(V expected);

        /// <summary> Verifies that the current value is less than or equal the given one.</summary>
        public INumberAssert<V> IsLessEqual(V expected);

        /// <summary> Verifies that the current value is greater than the given one.</summary>
        public INumberAssert<V> IsGreater(V expected);

        /// <summary> Verifies that the current value is greater than or equal the given one.</summary>
        public INumberAssert<V> IsGreaterEqual(V expected);

        /// <summary> Verifies that the current value is even.</summary>
        public INumberAssert<V> IsEven();

        /// <summary> Verifies that the current value is odd.</summary>
        public INumberAssert<V> IsOdd();

        /// <summary> Verifies that the current value is negative.</summary>
        public INumberAssert<V> IsNegative();

        /// <summary> Verifies that the current value is not negative.</summary>
        public INumberAssert<V> IsNotNegative();

        /// <summary> Verifies that the current value is equal to zero.</summary>
        public INumberAssert<V> IsZero();

        /// <summary> Verifies that the current value is not equal to zero.</summary>
        public INumberAssert<V> IsNotZero();

        /// <summary> Verifies that the current value is in the given set of values.</summary>
        public INumberAssert<V> IsIn(params V[] expected);

        /// <summary> Verifies that the current value is not in the given set of values.</summary>
        public INumberAssert<V> IsNotIn(params V[] expected);

        /// <summary> Verifies that the current value is between the given boundaries (inclusive).</summary>
        public INumberAssert<V> IsBetween(V from, V to);

        public new INumberAssert<V> OverrideFailureMessage(string message);
    }
}

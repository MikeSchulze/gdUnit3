namespace GdUnit3.Asserts
{
    /// <summary> An Assertion Tool to verify object values </summary>
    public interface IObjectAssert : IAssertBase<object>
    {
        // Verifies that the current value is the same as the given one.
        public IObjectAssert IsSame(object expected);

        // Verifies that the current value is not the same as the given one.
        public IObjectAssert IsNotSame(object expected);

        // Verifies that the current value is an instance of the given type.
        public IObjectAssert IsInstanceOf<ExpectedType>();

        // Verifies that the current value is not an instance of the given type.
        public IObjectAssert IsNotInstanceOf<ExpectedType>();

        public new IObjectAssert OverrideFailureMessage(string message);
    }
}

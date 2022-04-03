namespace GdUnit3.Asserts
{
    /// <summary> An Assertion Tool to verify boolean values </summary>
    public interface IBoolAssert : IAssertBase<bool>
    {

        /// <summary> Verifies that the current value is true.</summary>
        IBoolAssert IsTrue();

        /// <summary> Verifies that the current value is false.</summary>
        IBoolAssert IsFalse();

        new IBoolAssert OverrideFailureMessage(string message);
    }
}

namespace GdUnit3.Asserts
{
    /// <summary> An Assertion Tool to verify exceptions </summary>
    public interface IExceptionAssert : IAssert
    {
        /// <summary> Verifies the exception message is equal to expected one.</summary>
        IExceptionAssert HasMessage(string expected);

        /// <summary> Verifies that the exception message starts with the given value.</summary>
        IExceptionAssert StartsWithMessage(string value);


        /// <summary> Verifies that the exception message starts with the given value.</summary>
        IExceptionAssert IsInstanceOf<ExpectedType>();


        /// <summary> Verifies that the exception has the expected property value.</summary>
        IExceptionAssert HasPropertyValue(string propertyName, object expected);
    }
}

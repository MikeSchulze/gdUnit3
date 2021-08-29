using System.ComponentModel;

namespace GdUnit3
{

    /// <summary> Main interface of all GdUnit asserts </summary>
    public interface IAssert
    {

        enum EXPECT : int
        {
            [Description("assert expects ends with success")]
            SUCCESS = 0,
            [Description("assert expects ends with errors")]
            FAIL = 1
        }
    }

    /// <summary> Base interface of all GdUnit asserts </summary>
    public interface IAssertBase<V> : IAssert
    {

        /// <summary>Verifies that the current value is null.</summary>
        IAssertBase<V> IsNull();

        /// <summary> Verifies that the current value is not null.</summary>
        IAssertBase<V> IsNotNull();

        /// <summary> Verifies that the current value is equal to expected one.
        IAssertBase<V> IsEqual(V expected);

        /// <summary> Verifies that the current value is not equal to expected one.</summary>
        IAssertBase<V> IsNotEqual(V expected);

        /// <summary></summary>
        IAssertBase<V> TestFail();

        /// <summary> Verifies the failure message is equal to expected one.</summary>
        IAssertBase<V> HasFailureMessage(string expected);

        /// <summary> Verifies that the failure starts with the given value.</summary>
        IAssertBase<V> StartsWithFailureMessage(string value);

        /// <summary> Overrides the default failure message by given custom message.</summary>
        IAssertBase<V> OverrideFailureMessage(string message);
    }
}

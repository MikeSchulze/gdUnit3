namespace GdUnit3.Tests.Asserts
{
    using Executions;
    using Exceptions;
    using static Assertions;

    [TestSuite]
    public class BoolAssertTest
    {
        [TestCase]
        public void IsTrue()
        {
            AssertBool(true).IsTrue();
            AssertThrown(() => AssertBool(false).IsTrue())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 14)
                .HasMessage("Expecting: 'True' but is 'False'");
        }

        [TestCase]
        public void IsFalse()
        {
            AssertBool(false).IsFalse();
            AssertThrown(() => AssertBool(true).IsFalse())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 24)
                .HasMessage("Expecting: 'False' but is 'True'");
        }

        [TestCase]
        public void IsNull()
        {
            AssertThrown(() => AssertBool(true).IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 33)
                .StartsWithMessage("Expecting be <Null>:\n but is\n  'True'");
            AssertThrown(() => AssertBool(false).IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 37)
                .StartsWithMessage("Expecting be <Null>:\n but is\n  'False'");
        }

        [TestCase]
        public void IsNotNull()
        {
            AssertBool(true).IsNotNull();
            AssertBool(false).IsNotNull();
        }

        [TestCase]
        public void IsEqual()
        {
            AssertBool(true).IsEqual(true);
            AssertBool(false).IsEqual(false);
            AssertThrown(() => AssertBool(true).IsEqual(false))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 55)
                .HasMessage("Expecting be equal:\n"
                    + "  'False' but is 'True'");
        }

        [TestCase]
        public void IsNotEqual()
        {
            AssertBool(true).IsNotEqual(false);
            AssertBool(false).IsNotEqual(true);
            AssertThrown(() => AssertBool(true).IsNotEqual(true))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 67)
                .HasMessage("Expecting be NOT equal:\n"
                    + "  'True' but is 'True'");
        }

        [TestCase]
        public void Fluent()
        {
            AssertBool(true).IsTrue()
                .IsEqual(true)
                .IsNotEqual(false)
                .IsNotNull();
        }

        [TestCase]
        public void OverrideFailureMessage()
        {
            AssertThrown(() => AssertBool(true)
                        .OverrideFailureMessage("Custom failure message")
                        .IsFalse())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 86)
                .HasMessage("Custom failure message");
        }

        [TestCase]
        public void Interrupt_IsFailure()
        {
            // we disable failure reportion until we simmulate an failure
            ExecutionContext.Current.FailureReporting = false;
            // try to fail
            AssertBool(true).IsFalse();
            ExecutionContext.Current.FailureReporting = true;

            // expect this line will never called because of the test is inteerupted by a failing assert
            AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
        }
    }
}
